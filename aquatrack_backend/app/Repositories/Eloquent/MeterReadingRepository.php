<?php

namespace App\Repositories\Eloquent;

use App\Models\MeterReading;
use App\Models\User;
use App\Repositories\Contracts\MeterReadingRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class MeterReadingRepository implements MeterReadingRepositoryInterface
{
    public function paginateForUser(User $user, array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return MeterReading::query()
            ->with(['customer:id,full_name,customer_number,meter_number', 'inputBy:id,name,role'])
            ->when($user->role === User::ROLE_PELANGGAN && $user->customer, fn ($q) => $q->where('customer_id', $user->customer->id))
            ->when($filters['customer_id'] ?? null, fn ($q, $value) => $q->where('customer_id', $value))
            ->when($filters['period_year'] ?? null, fn ($q, $value) => $q->where('period_year', $value))
            ->when($filters['period_month'] ?? null, fn ($q, $value) => $q->where('period_month', $value))
            ->latest('reading_date')
            ->paginate($perPage);
    }

    public function create(array $data): MeterReading
    {
        return MeterReading::create($data);
    }

    public function update(MeterReading $meterReading, array $data): MeterReading
    {
        $meterReading->update($data);

        return $meterReading->refresh();
    }
}
