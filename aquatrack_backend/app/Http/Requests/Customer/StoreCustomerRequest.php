<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'full_name' => ['required', 'string', 'max:255'],
            'customer_number' => ['required', 'string', 'max:50', 'unique:customers,customer_number'],
            'meter_number' => ['required', 'string', 'max:50', 'unique:customers,meter_number'],
            'phone' => ['required', 'string', 'max:30'],
            'address' => ['required', 'string'],
            'status' => ['nullable', Rule::in(['active', 'inactive'])],
            'registered_at' => ['nullable', 'date'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
        ];
    }
}
