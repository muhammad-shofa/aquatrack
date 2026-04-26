<?php

namespace App\Repositories\Eloquent;

use App\Models\Customer;
use App\Repositories\Contracts\CustomerRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class CustomerRepository implements CustomerRepositoryInterface
{
    public function paginate(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return Customer::query()
            ->with('user:id,name,email,role')
            ->when($filters['search'] ?? null, function ($query, $search): void {
                $query->where(function ($sub) use ($search): void {
                    $sub->where('full_name', 'like', "%{$search}%")
                        ->orWhere('customer_number', 'like', "%{$search}%")
                        ->orWhere('meter_number', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%");
                });
            })
            ->when($filters['status'] ?? null, fn ($query, $status) => $query->where('status', $status))
            ->latest()
            ->paginate($perPage);
    }

    public function create(array $data): Customer
    {
        return Customer::create($data);
    }

    public function update(Customer $customer, array $data): Customer
    {
        $customer->update($data);

        return $customer->refresh();
    }

    public function delete(Customer $customer): bool
    {
        return (bool) $customer->delete();
    }
}
