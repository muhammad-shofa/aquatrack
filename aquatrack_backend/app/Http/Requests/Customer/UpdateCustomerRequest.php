<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $customerId = (int) $this->route('customer')->id;

        return [
            'full_name' => ['sometimes', 'string', 'max:255'],
            'customer_number' => ['sometimes', 'string', 'max:50', Rule::unique('customers', 'customer_number')->ignore($customerId)],
            'meter_number' => ['sometimes', 'string', 'max:50', Rule::unique('customers', 'meter_number')->ignore($customerId)],
            'phone' => ['sometimes', 'string', 'max:30'],
            'address' => ['sometimes', 'string'],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
            'registered_at' => ['sometimes', 'date'],
        ];
    }
}
