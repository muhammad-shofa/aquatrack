<?php

namespace App\Repositories\Eloquent;

use App\Models\Payment;
use App\Models\User;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class PaymentRepository implements PaymentRepositoryInterface
{
    public function paginate(array $filters, int $perPage = 15, ?User $user = null): LengthAwarePaginator
    {
        return Payment::query()
            ->with(['bill:id,invoice_number,total_amount,status', 'customer:id,full_name,customer_number'])
            ->when($user?->role === User::ROLE_PELANGGAN && $user->customer, fn ($q) => $q->where('customer_id', $user->customer->id))
            ->when($user?->role === User::ROLE_PENAGIH, fn ($q) => $q->where('collector_id', $user->id))
            ->when($filters['status'] ?? null, fn ($q, $status) => $q->where('status', $status))
            ->when($filters['bill_id'] ?? null, fn ($q, $billId) => $q->where('bill_id', $billId))
            ->latest()
            ->paginate($perPage);
    }

    public function create(array $data): Payment
    {
        return Payment::create($data);
    }

    public function update(Payment $payment, array $data): Payment
    {
        $payment->update($data);

        return $payment->refresh();
    }
}
