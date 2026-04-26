<?php

namespace App\Services;

use App\Models\Bill;
use App\Models\MeterReading;

class ReportService
{
    public function usageHistory(array $filters): array
    {
        $query = MeterReading::query()->with('customer:id,full_name,customer_number');

        if (! empty($filters['customer_id'])) {
            $query->where('customer_id', $filters['customer_id']);
        }

        if (! empty($filters['period_year'])) {
            $query->where('period_year', $filters['period_year']);
        }

        return $query->orderByDesc('period_year')->orderByDesc('period_month')->get()->toArray();
    }

    public function arrearsReport(): array
    {
        return Bill::query()
            ->with('customer:id,full_name,customer_number,phone')
            ->whereIn('status', ['unpaid', 'overdue', 'partially_paid'])
            ->get()
            ->toArray();
    }

    public function exportPlaceholder(string $format): array
    {
        return [
            'format' => $format,
            'status' => 'queued',
            'download_url' => null,
            'message' => 'Export service placeholder. Integrate Excel/PDF writer in worker.',
        ];
    }
}
