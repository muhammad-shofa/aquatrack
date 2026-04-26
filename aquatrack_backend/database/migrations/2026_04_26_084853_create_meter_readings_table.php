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
        Schema::create('meter_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->foreignId('input_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('input_source', ['penagih', 'pelanggan']);
            $table->unsignedTinyInteger('period_month');
            $table->unsignedSmallInteger('period_year');
            $table->unsignedInteger('previous_meter');
            $table->unsignedInteger('current_meter');
            $table->unsignedInteger('usage_m3');
            $table->date('reading_date');
            $table->enum('status', ['submitted', 'validated', 'rejected'])->default('submitted')->index();
            $table->text('notes')->nullable();
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
        Schema::dropIfExists('meter_readings');
    }
};
