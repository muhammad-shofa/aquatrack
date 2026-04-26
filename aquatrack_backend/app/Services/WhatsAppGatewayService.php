<?php

namespace App\Services;

use App\Models\Bill;
use App\Models\Customer;
use App\Models\NotificationLog;
use Illuminate\Support\Facades\Http;

class WhatsAppGatewayService
{
    public function sendBillAlert(Customer $customer, Bill $bill): NotificationLog
    {
        $message = sprintf(
            'Tagihan AQUATRACK %s periode %02d/%d sebesar Rp%s jatuh tempo %s.',
            $bill->invoice_number,
            $bill->period_month,
            $bill->period_year,
            number_format((float) $bill->total_amount, 0, ',', '.'),
            $bill->due_date->format('d-m-Y')
        );

        return $this->send($customer, $message, 'bill_alert', $bill);
    }

    public function sendDueReminder(Customer $customer, Bill $bill): NotificationLog
    {
        $message = sprintf(
            'Pengingat AQUATRACK: tagihan %s belum dibayar. Sisa tunggakan Rp%s.',
            $bill->invoice_number,
            number_format((float) $bill->total_amount, 0, ',', '.')
        );

        return $this->send($customer, $message, 'due_reminder', $bill);
    }

    private function send(Customer $customer, string $message, string $type, ?Bill $bill = null): NotificationLog
    {
        $response = Http::withToken(config('services.whatsapp.token'))
            ->post(config('services.whatsapp.url'), [
                'phone' => $customer->phone,
                'message' => $message,
            ]);

        return NotificationLog::query()->create([
            'customer_id' => $customer->id,
            'bill_id' => $bill?->id,
            'type' => $type,
            'channel' => 'whatsapp',
            'message' => $message,
            'status' => $response->successful() ? 'sent' : 'failed',
            'sent_at' => now(),
            'meta' => [
                'status_code' => $response->status(),
                'response' => $response->json(),
            ],
        ]);
    }
}
