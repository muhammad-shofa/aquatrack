<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    protected $fillable = [
        'bill_id',
        'customer_id',
        'collector_id',
        'paid_amount',
        'payment_date',
        'payment_method',
        'reference_number',
        'status',
        'verified_by',
        'verified_at',
        'verification_notes',
    ];

    protected function casts(): array
    {
        return [
            'paid_amount' => 'decimal:2',
            'payment_date' => 'date',
            'verified_at' => 'datetime',
        ];
    }

    public function bill(): BelongsTo
    {
        return $this->belongsTo(Bill::class);
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function collector(): BelongsTo
    {
        return $this->belongsTo(User::class, 'collector_id');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
