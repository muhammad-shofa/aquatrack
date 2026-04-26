<?php

namespace App\Services;

use App\Models\Bill;
use App\Models\Payment;
use App\Models\User;
use App\Repositories\Contracts\BillRepositoryInterface;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class PaymentService
{
    public function __construct(
        private readonly PaymentRepositoryInterface $paymentRepository,
        private readonly BillRepositoryInterface $billRepository,
    ) {
    }

    public function create(array $data, User $user): Payment
    {
        return DB::transaction(function () use ($data, $user): Payment {
            $bill = Bill::query()->findOrFail($data['bill_id']);

            if ($user->role === User::ROLE_PELANGGAN && $user->customer?->id !== $bill->customer_id) {
                throw new RuntimeException('You can only pay your own bills.');
            }

            if ($bill->status === 'paid') {
                throw new RuntimeException('Bill already paid.');
            }

            return $this->paymentRepository->create([
                'bill_id' => $bill->id,
                'customer_id' => $bill->customer_id,
                'collector_id' => $user->role === User::ROLE_PENAGIH ? $user->id : null,
                'paid_amount' => $data['paid_amount'],
                'payment_date' => $data['payment_date'],
                'payment_method' => $data['payment_method'],
                'reference_number' => $data['reference_number'] ?? null,
                'status' => 'pending',
            ]);
        });
    }

    public function verify(Payment $payment, array $data, User $admin): Payment
    {
        return DB::transaction(function () use ($payment, $data, $admin): Payment {
            $payment = $this->paymentRepository->update($payment, [
                'status' => $data['status'],
                'verification_notes' => $data['verification_notes'] ?? null,
                'verified_by' => $admin->id,
                'verified_at' => now(),
            ]);

            if ($data['status'] !== 'verified') {
                return $payment;
            }

            $bill = $payment->bill()->firstOrFail();
            $paid = (float) $bill->payments()->where('status', 'verified')->sum('paid_amount');

            if ($paid >= (float) $bill->total_amount) {
                $this->billRepository->update($bill, [
                    'status' => 'paid',
                    'paid_at' => now(),
                ]);
            } else {
                $this->billRepository->update($bill, [
                    'status' => 'partially_paid',
                ]);
            }

            return $payment->refresh();
        });
    }
}
