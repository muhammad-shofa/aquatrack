<?php

namespace App\Http\Requests\MeterReading;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateMeterReadingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'previous_meter' => ['sometimes', 'integer', 'min:0'],
            'current_meter' => ['sometimes', 'integer', 'min:0'],
            'reading_date' => ['sometimes', 'date'],
            'notes' => ['nullable', 'string'],
            'status' => ['sometimes', Rule::in(['submitted', 'validated', 'rejected'])],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $previous = (int) ($this->input('previous_meter') ?? $this->route('meter_reading')->previous_meter);
            $current = (int) ($this->input('current_meter') ?? $this->route('meter_reading')->current_meter);

            if ($current <= $previous) {
                $validator->errors()->add('current_meter', 'Current meter must be greater than previous meter.');
            }
        });
    }
}
