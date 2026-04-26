<?php

namespace App\Repositories\Contracts;

use App\Models\Tariff;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface TariffRepositoryInterface
{
    public function paginate(int $perPage = 15): LengthAwarePaginator;

    public function create(array $data): Tariff;

    public function update(Tariff $tariff, array $data): Tariff;

    public function delete(Tariff $tariff): bool;

    public function getActiveTariff(): ?Tariff;
}
