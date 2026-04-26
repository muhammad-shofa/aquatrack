<?php

namespace App\Repositories\Contracts;

use App\Models\Bill;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

interface BillRepositoryInterface
{
    public function paginateForUser(User $user, array $filters, int $perPage = 15): LengthAwarePaginator;

    public function create(array $data): Bill;

    public function update(Bill $bill, array $data): Bill;

    public function arrears(): Collection;
}
