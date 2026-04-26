<?php

namespace App\Services;

use App\Models\Bill;
use App\Models\MeterReading;
use App\Repositories\Contracts\BillRepositoryInterface;
use App\Repositories\Contracts\TariffRepositoryInterface;
use Illuminate\Support\Str;
use RuntimeException;

class BillingService
{
    public function __construct(
        private readonly BillRepositoryInterface $billRepository,
        private readonly TariffRepositoryInterface $tariffRepository,
    ) {
    }

    public function generateFromMeterReading(MeterReading $meterReading): Bill
    {
        $tariff = $this->tariffRepository->getActiveTariff();

        if (! $tariff) {
            throw new RuntimeException('No active tariff is configured.');
        }

        $usage = $meterReading->current_meter - $meterReading->previous_meter;
        $subtotal = max($usage * (float) $tariff->price_per_m3, (float) $tariff->minimum_charge);
        $total = $subtotal;

        return $this->billRepository->create([
            'customer_id' => $meterReading->customer_id,
            'meter_reading_id' => $meterReading->id,
            'tariff_id' => $tariff->id,
            'invoice_number' => $this->generateInvoiceNumber($meterReading->period_year, $meterReading->period_month),
            'period_month' => $meterReading->period_month,
            'period_year' => $meterReading->period_year,
            'usage_m3' => $usage,
            'tariff_per_m3' => $tariff->price_per_m3,
            'subtotal' => $subtotal,
            'penalty_amount' => 0,
            'total_amount' => $total,
            'due_date' => now()->setDate($meterReading->period_year, $meterReading->period_month, 20),
            'status' => 'unpaid',
            'generated_at' => now(),
        ]);
    }

    public function applyLatePenalty(Bill $bill): Bill
    {
        $bill->loadMissing('tariff');

        if ($bill->status === 'paid' || $bill->due_date->isFuture()) {
            return $bill;
        }

        $lateDays = now()->diffInDays($bill->due_date);
        $dailyFee = (float) $bill->tariff->late_fee_daily;
        $penalty = $lateDays * $dailyFee;

        return $this->billRepository->update($bill, [
            'penalty_amount' => $penalty,
            'total_amount' => (float) $bill->subtotal + $penalty,
            'status' => 'overdue',
        ]);
    }

    private function generateInvoiceNumber(int $year, int $month): string
    {
        return sprintf('AQ-%d%02d-%s', $year, $month, Str::upper(Str::random(6)));
    }
}
