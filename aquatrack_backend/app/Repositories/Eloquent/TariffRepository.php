<?php

namespace App\Repositories\Eloquent;

use App\Models\Tariff;
use App\Repositories\Contracts\TariffRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class TariffRepository implements TariffRepositoryInterface
{
    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return Tariff::query()->latest('effective_start_date')->paginate($perPage);
    }

    public function create(array $data): Tariff
    {
        return Tariff::create($data);
    }

    public function update(Tariff $tariff, array $data): Tariff
    {
        $tariff->update($data);

        return $tariff->refresh();
    }

    public function delete(Tariff $tariff): bool
    {
        return (bool) $tariff->delete();
    }

    public function getActiveTariff(): ?Tariff
    {
        return Tariff::query()
            ->where('is_active', true)
            ->whereDate('effective_start_date', '<=', now()->toDateString())
            ->where(function ($query): void {
                $query->whereNull('effective_end_date')
                    ->orWhereDate('effective_end_date', '>=', now()->toDateString());
            })
            ->orderByDesc('effective_start_date')
            ->first();
    }
}
