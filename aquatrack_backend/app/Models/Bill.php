<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Bill extends Model
{
    protected $fillable = [
        'customer_id',
        'meter_reading_id',
        'tariff_id',
        'invoice_number',
        'period_month',
        'period_year',
        'usage_m3',
        'tariff_per_m3',
        'subtotal',
        'penalty_amount',
        'total_amount',
        'due_date',
        'status',
        'generated_at',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'tariff_per_m3' => 'decimal:2',
            'subtotal' => 'decimal:2',
            'penalty_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'due_date' => 'date',
            'generated_at' => 'datetime',
            'paid_at' => 'datetime',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function meterReading(): BelongsTo
    {
        return $this->belongsTo(MeterReading::class);
    }

    public function tariff(): BelongsTo
    {
        return $this->belongsTo(Tariff::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function notificationLogs(): HasMany
    {
        return $this->hasMany(NotificationLog::class);
    }

    protected function outstandingAmount(): Attribute
    {
        return Attribute::make(
            get: fn (): float => (float) $this->total_amount - (float) $this->payments()->where('status', 'verified')->sum('paid_amount')
        );
    }
}
