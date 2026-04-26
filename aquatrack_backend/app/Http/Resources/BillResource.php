<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BillResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'invoice_number' => $this->invoice_number,
            'customer_id' => $this->customer_id,
            'meter_reading_id' => $this->meter_reading_id,
            'tariff_id' => $this->tariff_id,
            'period_month' => $this->period_month,
            'period_year' => $this->period_year,
            'usage_m3' => $this->usage_m3,
            'tariff_per_m3' => (float) $this->tariff_per_m3,
            'subtotal' => (float) $this->subtotal,
            'penalty_amount' => (float) $this->penalty_amount,
            'total_amount' => (float) $this->total_amount,
            'outstanding_amount' => (float) $this->outstanding_amount,
            'due_date' => $this->due_date?->toDateString(),
            'status' => $this->status,
            'paid_at' => $this->paid_at?->toDateTimeString(),
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'meter_reading' => new MeterReadingResource($this->whenLoaded('meterReading')),
        ];
    }
}
