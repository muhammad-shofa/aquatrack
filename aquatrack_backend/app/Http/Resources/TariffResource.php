<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TariffResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price_per_m3' => (float) $this->price_per_m3,
            'minimum_charge' => (float) $this->minimum_charge,
            'late_fee_daily' => (float) $this->late_fee_daily,
            'effective_start_date' => $this->effective_start_date?->toDateString(),
            'effective_end_date' => $this->effective_end_date?->toDateString(),
            'is_active' => (bool) $this->is_active,
        ];
    }
}
