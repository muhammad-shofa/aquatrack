<?php

namespace App\Repositories\Eloquent;

use App\Models\Bill;
use App\Models\User;
use App\Repositories\Contracts\BillRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class BillRepository implements BillRepositoryInterface
{
    public function paginateForUser(User $user, array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return Bill::query()
            ->with(['customer:id,full_name,customer_number', 'meterReading:id,customer_id,current_meter,previous_meter,usage_m3'])
            ->when($user->role === User::ROLE_PELANGGAN && $user->customer, fn ($q) => $q->where('customer_id', $user->customer->id))
            ->when($filters['status'] ?? null, fn ($q, $status) => $q->where('status', $status))
            ->when($filters['customer_id'] ?? null, fn ($q, $customerId) => $q->where('customer_id', $customerId))
            ->when($filters['period_year'] ?? null, fn ($q, $year) => $q->where('period_year', $year))
            ->when($filters['period_month'] ?? null, fn ($q, $month) => $q->where('period_month', $month))
            ->orderByDesc('period_year')
            ->orderByDesc('period_month')
            ->paginate($perPage);
    }

    public function create(array $data): Bill
    {
        return Bill::create($data);
    }

    public function update(Bill $bill, array $data): Bill
    {
        $bill->update($data);

        return $bill->refresh();
    }

    public function arrears(): Collection
    {
        return Bill::query()
            ->with('customer:id,full_name,customer_number,phone')
            ->whereIn('status', ['unpaid', 'overdue', 'partially_paid'])
            ->whereDate('due_date', '<', now()->toDateString())
            ->orderBy('due_date')
            ->get();
    }
}
