<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\BillResource;
use App\Models\Bill;
use App\Models\User;
use App\Repositories\Contracts\BillRepositoryInterface;
use App\Services\BillingService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BillController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly BillRepositoryInterface $billRepository,
        private readonly BillingService $billingService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $bills = $this->billRepository->paginateForUser(
            $request->user(),
            $request->only(['status', 'customer_id', 'period_month', 'period_year']),
            (int) $request->integer('per_page', 15)
        );

        foreach ($bills->items() as $bill) {
            if (in_array($bill->status, ['unpaid', 'partially_paid', 'overdue'], true) && $bill->due_date->isPast()) {
                $this->billingService->applyLatePenalty($bill);
            }
        }

        return $this->successResponse(BillResource::collection($bills), 'Bill list.');
    }

    public function show(Bill $bill): JsonResponse
    {
        $user = request()->user();

        if ($user->role === User::ROLE_PELANGGAN && $user->customer?->id !== $bill->customer_id) {
            return $this->errorResponse('Unauthorized access to bill.', null, 403);
        }

        $bill->load(['customer', 'meterReading', 'payments']);

        return $this->successResponse(new BillResource($bill), 'Bill detail.');
    }

    public function applyPenalty(Bill $bill): JsonResponse
    {
        $updated = $this->billingService->applyLatePenalty($bill->load('tariff'));

        return $this->successResponse(new BillResource($updated->load(['customer', 'meterReading'])), 'Penalty applied.');
    }

    public function arrears(): JsonResponse
    {
        $arrears = $this->billRepository->arrears();

        return $this->successResponse(BillResource::collection($arrears), 'Arrears list.');
    }
}
