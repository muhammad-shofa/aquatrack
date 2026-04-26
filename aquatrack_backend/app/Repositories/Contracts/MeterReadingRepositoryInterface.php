<?php

namespace App\Repositories\Contracts;

use App\Models\MeterReading;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface MeterReadingRepositoryInterface
{
    public function paginateForUser(User $user, array $filters, int $perPage = 15): LengthAwarePaginator;

    public function create(array $data): MeterReading;

    public function update(MeterReading $meterReading, array $data): MeterReading;
}
