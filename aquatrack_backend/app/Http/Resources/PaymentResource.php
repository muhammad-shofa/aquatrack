<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'bill_id' => $this->bill_id,
            'customer_id' => $this->customer_id,
            'collector_id' => $this->collector_id,
            'paid_amount' => (float) $this->paid_amount,
            'payment_date' => $this->payment_date?->toDateString(),
            'payment_method' => $this->payment_method,
            'reference_number' => $this->reference_number,
            'status' => $this->status,
            'verified_by' => $this->verified_by,
            'verified_at' => $this->verified_at?->toDateTimeString(),
            'verification_notes' => $this->verification_notes,
            'bill' => new BillResource($this->whenLoaded('bill')),
            'customer' => new CustomerResource($this->whenLoaded('customer')),
        ];
    }
}
