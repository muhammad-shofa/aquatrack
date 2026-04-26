<?php

namespace App\Http\Requests\Tariff;

use Illuminate\Foundation\Http\FormRequest;

class StoreTariffRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:120'],
            'price_per_m3' => ['required', 'numeric', 'min:0'],
            'minimum_charge' => ['nullable', 'numeric', 'min:0'],
            'late_fee_daily' => ['nullable', 'numeric', 'min:0'],
            'effective_start_date' => ['required', 'date'],
            'effective_end_date' => ['nullable', 'date', 'after_or_equal:effective_start_date'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }
}
