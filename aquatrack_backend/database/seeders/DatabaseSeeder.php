<?php

namespace Database\Seeders;

use App\Models\Bill;
use App\Models\Customer;
use App\Models\MeterReading;
use App\Models\NotificationLog;
use App\Models\Payment;
use App\Models\Tariff;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $admin = User::query()->create([
            'name' => 'Admin AQUATRACK',
            'email' => 'admin@aquatrack.test',
            'password' => Hash::make('password'),
            'phone' => '081200000001',
            'role' => User::ROLE_ADMIN,
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        $collector = User::query()->create([
            'name' => 'Penagih AQUATRACK',
            'email' => 'penagih@aquatrack.test',
            'password' => Hash::make('password'),
            'phone' => '081200000002',
            'role' => User::ROLE_PENAGIH,
            'is_active' => true,
            'email_verified_at' => now(),
        ]);

        $tariff = Tariff::query()->create([
            'name' => 'Tarif Rumah Tangga 2026',
            'price_per_m3' => 4500,
            'minimum_charge' => 20000,
            'late_fee_daily' => 1500,
            'effective_start_date' => now()->startOfYear()->toDateString(),
            'is_active' => true,
        ]);

        for ($i = 1; $i <= 12; $i++) {
            $user = User::query()->create([
                'name' => "Pelanggan {$i}",
                'email' => "pelanggan{$i}@aquatrack.test",
                'password' => Hash::make('password'),
                'phone' => '0813000'.str_pad((string) $i, 4, '0', STR_PAD_LEFT),
                'role' => User::ROLE_PELANGGAN,
                'is_active' => true,
                'email_verified_at' => now(),
            ]);

            $customer = Customer::query()->create([
                'user_id' => $user->id,
                'customer_number' => 'CUST-'.str_pad((string) $i, 5, '0', STR_PAD_LEFT),
                'meter_number' => 'MTR-'.str_pad((string) $i, 6, '0', STR_PAD_LEFT),
                'full_name' => $user->name,
                'phone' => $user->phone,
                'address' => fake()->address(),
                'status' => 'active',
                'registered_at' => now()->subMonths(rand(1, 24))->toDateString(),
            ]);

            $previous = rand(100, 200);
            foreach ([now()->subMonth(), now()] as $periodDate) {
                $current = $previous + rand(10, 40);
                $reading = MeterReading::query()->create([
                    'customer_id' => $customer->id,
                    'input_by_user_id' => $i % 3 === 0 ? $user->id : $collector->id,
                    'input_source' => $i % 3 === 0 ? User::ROLE_PELANGGAN : User::ROLE_PENAGIH,
                    'period_month' => $periodDate->month,
                    'period_year' => $periodDate->year,
                    'previous_meter' => $previous,
                    'current_meter' => $current,
                    'usage_m3' => $current - $previous,
                    'reading_date' => $periodDate->copy()->day(5)->toDateString(),
                    'status' => 'validated',
                ]);

                $subtotal = max($reading->usage_m3 * (float) $tariff->price_per_m3, (float) $tariff->minimum_charge);
                $isOverdue = $periodDate->isPast() && $i % 4 === 0;
                $bill = Bill::query()->create([
                    'customer_id' => $customer->id,
                    'meter_reading_id' => $reading->id,
                    'tariff_id' => $tariff->id,
                    'invoice_number' => 'AQ-'.$periodDate->format('Ym').'-'.Str::upper(Str::random(6)),
                    'period_month' => $periodDate->month,
                    'period_year' => $periodDate->year,
                    'usage_m3' => $reading->usage_m3,
                    'tariff_per_m3' => $tariff->price_per_m3,
                    'subtotal' => $subtotal,
                    'penalty_amount' => $isOverdue ? 7500 : 0,
                    'total_amount' => $subtotal + ($isOverdue ? 7500 : 0),
                    'due_date' => $periodDate->copy()->day(20)->toDateString(),
                    'status' => $isOverdue ? 'overdue' : ($i % 2 === 0 ? 'paid' : 'unpaid'),
                    'generated_at' => $periodDate->copy()->day(8),
                    'paid_at' => $i % 2 === 0 ? now()->subDays(rand(1, 20)) : null,
                ]);

                if ($i % 2 === 0) {
                    Payment::query()->create([
                        'bill_id' => $bill->id,
                        'customer_id' => $customer->id,
                        'collector_id' => $collector->id,
                        'paid_amount' => $bill->total_amount,
                        'payment_date' => now()->subDays(rand(1, 20))->toDateString(),
                        'payment_method' => 'cash',
                        'reference_number' => 'PAY-'.Str::upper(Str::random(8)),
                        'status' => 'verified',
                        'verified_by' => $admin->id,
                        'verified_at' => now()->subDays(rand(1, 10)),
                    ]);
                } elseif ($isOverdue) {
                    NotificationLog::query()->create([
                        'customer_id' => $customer->id,
                        'bill_id' => $bill->id,
                        'type' => 'due_reminder',
                        'channel' => 'whatsapp',
                        'message' => 'Pengingat tunggakan pembayaran tagihan AQUATRACK.',
                        'status' => 'sent',
                        'sent_at' => now()->subDays(rand(1, 5)),
                        'meta' => ['seed' => true],
                    ]);
                }

                $previous = $current;
            }
        }

        User::factory(2)->create([
            'role' => User::ROLE_PENAGIH,
            'is_active' => true,
        ]);
    }
}
