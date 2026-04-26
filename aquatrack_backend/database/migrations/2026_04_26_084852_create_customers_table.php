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
        Schema::create('customers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->unique()->constrained()->nullOnDelete();
            $table->string('customer_number')->unique();
            $table->string('meter_number')->unique();
            $table->string('full_name');
            $table->string('phone', 30);
            $table->text('address');
            $table->enum('status', ['active', 'inactive'])->default('active')->index();
            $table->date('registered_at')->nullable();
            $table->timestamps();

            $table->index(['full_name', 'phone']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('customers');
    }
};
