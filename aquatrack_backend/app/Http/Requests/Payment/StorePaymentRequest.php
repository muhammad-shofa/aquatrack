<?php

namespace App\Http\Requests\Payment;

use Illuminate\Foundation\Http\FormRequest;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'bill_id' => ['required', 'exists:bills,id'],
            'paid_amount' => ['required', 'numeric', 'min:1'],
            'payment_date' => ['required', 'date'],
            'payment_method' => ['required', 'string', 'max:30'],
            'reference_number' => ['nullable', 'string', 'max:120'],
        ];
    }
}
