<?php

namespace App\Services;

use App\Models\Bill;
use App\Models\Customer;
use App\Models\MeterReading;
use App\Models\Payment;
use App\Models\User;

class DashboardService
{
    public function adminStats(): array
    {
        return [
            'total_customers' => Customer::query()->count(),
            'active_customers' => Customer::query()->where('status', 'active')->count(),
            'total_unpaid_bills' => Bill::query()->whereIn('status', ['unpaid', 'overdue', 'partially_paid'])->count(),
            'total_arrears_amount' => (float) Bill::query()->whereIn('status', ['unpaid', 'overdue', 'partially_paid'])->sum('total_amount'),
            'verified_payments_this_month' => (float) Payment::query()
                ->where('status', 'verified')
                ->whereMonth('payment_date', now()->month)
                ->whereYear('payment_date', now()->year)
                ->sum('paid_amount'),
            'readings_this_month' => MeterReading::query()
                ->where('period_month', now()->month)
                ->where('period_year', now()->year)
                ->count(),
        ];
    }

    public function collectorStats(User $collector): array
    {
        return [
            'collector' => [
                'id' => $collector->id,
                'name' => $collector->name,
            ],
            'readings_inputted' => MeterReading::query()->where('input_by_user_id', $collector->id)->count(),
            'payments_collected' => (float) Payment::query()
                ->where('collector_id', $collector->id)
                ->where('status', 'verified')
                ->sum('paid_amount'),
            'pending_verification_payments' => Payment::query()
                ->where('collector_id', $collector->id)
                ->where('status', 'pending')
                ->count(),
        ];
    }
}
