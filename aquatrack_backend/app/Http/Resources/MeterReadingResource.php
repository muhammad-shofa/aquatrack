<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MeterReadingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'customer_id' => $this->customer_id,
            'input_by_user_id' => $this->input_by_user_id,
            'input_source' => $this->input_source,
            'period_month' => $this->period_month,
            'period_year' => $this->period_year,
            'previous_meter' => $this->previous_meter,
            'current_meter' => $this->current_meter,
            'usage_m3' => $this->usage_m3,
            'reading_date' => $this->reading_date?->toDateString(),
            'status' => $this->status,
            'notes' => $this->notes,
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'input_by' => new UserResource($this->whenLoaded('inputBy')),
        ];
    }
}
