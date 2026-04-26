<?php

namespace App\Http\Requests\Tariff;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTariffRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:120'],
            'price_per_m3' => ['sometimes', 'numeric', 'min:0'],
            'minimum_charge' => ['sometimes', 'numeric', 'min:0'],
            'late_fee_daily' => ['sometimes', 'numeric', 'min:0'],
            'effective_start_date' => ['sometimes', 'date'],
            'effective_end_date' => ['nullable', 'date'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
