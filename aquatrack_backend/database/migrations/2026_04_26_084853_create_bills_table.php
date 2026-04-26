<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('bills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('meter_reading_id');
            $table->foreignId('tariff_id')->constrained()->restrictOnDelete();
            $table->string('invoice_number')->unique();
            $table->unsignedTinyInteger('period_month');
            $table->unsignedSmallInteger('period_year');
            $table->unsignedInteger('usage_m3');
            $table->decimal('tariff_per_m3', 12, 2);
            $table->decimal('subtotal', 12, 2);
            $table->decimal('penalty_amount', 12, 2)->default(0);
            $table->decimal('total_amount', 12, 2);
            $table->date('due_date')->index();
            $table->enum('status', ['unpaid', 'partially_paid', 'paid', 'overdue'])->default('unpaid')->index();
            $table->timestamp('generated_at');
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->unique(['customer_id', 'period_month', 'period_year']);
            $table->index(['period_year', 'period_month']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bills');
    }
};
