<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\StoreCustomerRequest;
use App\Http\Requests\Customer\UpdateCustomerRequest;
use App\Http\Resources\CustomerResource;
use App\Models\Customer;
use App\Models\User;
use App\Repositories\Contracts\CustomerRepositoryInterface;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class CustomerController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly CustomerRepositoryInterface $customerRepository)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $customers = $this->customerRepository->paginate($request->only(['search', 'status']), (int) $request->integer('per_page', 15));

        return $this->successResponse(CustomerResource::collection($customers), 'Customer list.');
    }

    public function store(StoreCustomerRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $user = User::query()->create([
            'name' => $validated['full_name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'],
            'role' => User::ROLE_PELANGGAN,
            'is_active' => true,
        ]);

        $customer = $this->customerRepository->create([
            'user_id' => $user->id,
            'customer_number' => $validated['customer_number'],
            'meter_number' => $validated['meter_number'],
            'full_name' => $validated['full_name'],
            'phone' => $validated['phone'],
            'address' => $validated['address'],
            'status' => $validated['status'] ?? 'active',
            'registered_at' => $validated['registered_at'] ?? now()->toDateString(),
        ])->load('user');

        return $this->successResponse(new CustomerResource($customer), 'Customer created.', 201);
    }

    public function show(Customer $customer): JsonResponse
    {
        return $this->successResponse(new CustomerResource($customer->load('user')), 'Customer detail.');
    }

    public function update(UpdateCustomerRequest $request, Customer $customer): JsonResponse
    {
        $data = $request->validated();
        $updated = $this->customerRepository->update($customer, $data)->load('user');

        if ($updated->user) {
            $updated->user->update([
                'name' => $data['full_name'] ?? $updated->user->name,
                'phone' => $data['phone'] ?? $updated->user->phone,
            ]);
        }

        return $this->successResponse(new CustomerResource($updated), 'Customer updated.');
    }

    public function destroy(Customer $customer): JsonResponse
    {
        $user = $customer->user;
        $this->customerRepository->delete($customer);
        $user?->delete();

        return $this->successResponse(null, 'Customer deleted.');
    }

    public function myProfile(Request $request): JsonResponse
    {
        $customer = $request->user()->customer;

        if (! $customer) {
            return $this->errorResponse('Customer profile not found.', null, 404);
        }

        return $this->successResponse(new CustomerResource($customer->load('user')), 'Customer profile.');
    }
}
