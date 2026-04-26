<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Services\WhatsAppGatewayService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class NotificationController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly WhatsAppGatewayService $whatsAppGatewayService)
    {
    }

    public function billAlert(Bill $bill): JsonResponse
    {
        $log = $this->whatsAppGatewayService->sendBillAlert($bill->customer, $bill);

        return $this->successResponse($log, 'Bill alert sent.');
    }

    public function dueReminder(Bill $bill): JsonResponse
    {
        $log = $this->whatsAppGatewayService->sendDueReminder($bill->customer, $bill);

        return $this->successResponse($log, 'Due reminder sent.');
    }
}
