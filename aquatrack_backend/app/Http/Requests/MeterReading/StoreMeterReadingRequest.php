<?php

namespace App\Http\Requests\MeterReading;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMeterReadingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['nullable', 'exists:customers,id'],
            'period_month' => ['required', 'integer', 'between:1,12'],
            'period_year' => ['required', 'integer', 'min:2000', 'max:2100'],
            'previous_meter' => ['required', 'integer', 'min:0'],
            'current_meter' => ['required', 'integer', 'gt:previous_meter'],
            'reading_date' => ['required', 'date'],
            'notes' => ['nullable', 'string'],
            'status' => ['nullable', Rule::in(['submitted', 'validated', 'rejected'])],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $customerId = $this->input('customer_id') ?: $this->user()?->customer?->id;

            if (! $customerId) {
                return;
            }

            $exists = \App\Models\MeterReading::query()
                ->where('customer_id', $customerId)
                ->where('period_month', $this->input('period_month'))
                ->where('period_year', $this->input('period_year'))
                ->exists();

            if ($exists) {
                $validator->errors()->add('period_month', 'Meter reading for this period already exists.');
            }
        });
    }
}
