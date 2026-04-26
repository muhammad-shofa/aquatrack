<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Payment\StorePaymentRequest;
use App\Http\Requests\Payment\VerifyPaymentRequest;
use App\Http\Resources\PaymentResource;
use App\Models\Payment;
use App\Models\User;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Services\PaymentService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class PaymentController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly PaymentRepositoryInterface $paymentRepository,
        private readonly PaymentService $paymentService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $payments = $this->paymentRepository->paginate(
            $request->only(['status', 'bill_id']),
            (int) $request->integer('per_page', 15),
            $request->user()
        );

        return $this->successResponse(PaymentResource::collection($payments), 'Payment list.');
    }

    public function store(StorePaymentRequest $request): JsonResponse
    {
        try {
            $payment = $this->paymentService->create($request->validated(), $request->user());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), null, 422);
        }

        return $this->successResponse(new PaymentResource($payment->load(['bill', 'customer'])), 'Payment submitted.', 201);
    }

    public function show(Payment $payment): JsonResponse
    {
        if ($requestUser = request()->user()) {
            if ($requestUser->role === User::ROLE_PELANGGAN && $requestUser->customer?->id !== $payment->customer_id) {
                return $this->errorResponse('Unauthorized access to payment.', null, 403);
            }

            if ($requestUser->role === User::ROLE_PENAGIH && $payment->collector_id !== $requestUser->id) {
                return $this->errorResponse('Unauthorized access to payment.', null, 403);
            }
        }

        return $this->successResponse(new PaymentResource($payment->load(['bill', 'customer'])), 'Payment detail.');
    }

    public function verify(VerifyPaymentRequest $request, Payment $payment): JsonResponse
    {
        $verified = $this->paymentService->verify($payment, $request->validated(), $request->user());

        return $this->successResponse(new PaymentResource($verified->load(['bill', 'customer'])), 'Payment verification updated.');
    }
}
