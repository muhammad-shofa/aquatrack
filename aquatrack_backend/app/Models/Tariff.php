<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Tariff extends Model
{
    protected $fillable = [
        'name',
        'price_per_m3',
        'minimum_charge',
        'late_fee_daily',
        'effective_start_date',
        'effective_end_date',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'price_per_m3' => 'decimal:2',
            'minimum_charge' => 'decimal:2',
            'late_fee_daily' => 'decimal:2',
            'effective_start_date' => 'date',
            'effective_end_date' => 'date',
            'is_active' => 'boolean',
        ];
    }

    public function bills(): HasMany
    {
        return $this->hasMany(Bill::class);
    }
}
