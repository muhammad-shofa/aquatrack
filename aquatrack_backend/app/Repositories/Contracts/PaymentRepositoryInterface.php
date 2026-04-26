<?php

namespace App\Repositories\Contracts;

use App\Models\Payment;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface PaymentRepositoryInterface
{
    public function paginate(array $filters, int $perPage = 15, ?User $user = null): LengthAwarePaginator;

    public function create(array $data): Payment;

    public function update(Payment $payment, array $data): Payment;
}
