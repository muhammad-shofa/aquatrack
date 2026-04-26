<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'customer_number' => $this->customer_number,
            'meter_number' => $this->meter_number,
            'full_name' => $this->full_name,
            'phone' => $this->phone,
            'address' => $this->address,
            'status' => $this->status,
            'registered_at' => $this->registered_at?->toDateString(),
            'user' => new UserResource($this->whenLoaded('user')),
        ];
    }
}
