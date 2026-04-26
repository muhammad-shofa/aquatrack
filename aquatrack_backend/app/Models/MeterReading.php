<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class MeterReading extends Model
{
    protected $fillable = [
        'customer_id',
        'input_by_user_id',
        'input_source',
        'period_month',
        'period_year',
        'previous_meter',
        'current_meter',
        'usage_m3',
        'reading_date',
        'status',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'reading_date' => 'date',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function inputBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'input_by_user_id');
    }

    public function bill(): HasOne
    {
        return $this->hasOne(Bill::class);
    }
}
