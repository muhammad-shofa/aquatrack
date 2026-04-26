<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\MeterReading\StoreMeterReadingRequest;
use App\Http\Requests\MeterReading\UpdateMeterReadingRequest;
use App\Http\Resources\MeterReadingResource;
use App\Models\MeterReading;
use App\Models\User;
use App\Repositories\Contracts\MeterReadingRepositoryInterface;
use App\Services\BillingService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class MeterReadingController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly MeterReadingRepositoryInterface $meterReadingRepository,
        private readonly BillingService $billingService,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $readings = $this->meterReadingRepository->paginateForUser(
            $request->user(),
            $request->only(['customer_id', 'period_month', 'period_year']),
            (int) $request->integer('per_page', 15)
        );

        return $this->successResponse(MeterReadingResource::collection($readings), 'Meter reading list.');
    }

    public function store(StoreMeterReadingRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $customerId = $user->role === User::ROLE_PELANGGAN
            ? $user->customer?->id
            : $validated['customer_id'];

        if (! $customerId) {
            return $this->errorResponse('Customer target is required.', null, 422);
        }

        $current = (int) $validated['current_meter'];
        $previous = (int) $validated['previous_meter'];
        $reading = $this->meterReadingRepository->create([
            'customer_id' => $customerId,
            'input_by_user_id' => $user->id,
            'input_source' => $user->role === User::ROLE_PELANGGAN ? User::ROLE_PELANGGAN : User::ROLE_PENAGIH,
            'period_month' => $validated['period_month'],
            'period_year' => $validated['period_year'],
            'previous_meter' => $previous,
            'current_meter' => $current,
            'usage_m3' => $current - $previous,
            'reading_date' => $validated['reading_date'],
            'status' => $validated['status'] ?? 'submitted',
            'notes' => $validated['notes'] ?? null,
        ]);

        try {
            $bill = $this->billingService->generateFromMeterReading($reading);
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), null, 422);
        }

        return $this->successResponse([
            'meter_reading' => new MeterReadingResource($reading->load(['customer', 'inputBy'])),
            'bill_id' => $bill->id,
        ], 'Meter reading created and bill generated.', 201);
    }

    public function show(MeterReading $meterReading): JsonResponse
    {
        if ($this->isForbiddenForCustomer($meterReading)) {
            return $this->errorResponse('Unauthorized access to meter reading.', null, 403);
        }

        return $this->successResponse(new MeterReadingResource($meterReading->load(['customer', 'inputBy'])), 'Meter reading detail.');
    }

    public function update(UpdateMeterReadingRequest $request, MeterReading $meterReading): JsonResponse
    {
        if ($this->isForbiddenForCustomer($meterReading)) {
            return $this->errorResponse('Unauthorized update action.', null, 403);
        }

        $payload = $request->validated();
        $previous = (int) ($payload['previous_meter'] ?? $meterReading->previous_meter);
        $current = (int) ($payload['current_meter'] ?? $meterReading->current_meter);
        $payload['usage_m3'] = $current - $previous;

        $updated = $this->meterReadingRepository->update($meterReading, $payload);

        return $this->successResponse(new MeterReadingResource($updated->load(['customer', 'inputBy'])), 'Meter reading updated.');
    }

    private function isForbiddenForCustomer(MeterReading $meterReading): bool
    {
        $user = request()->user();

        return $user->role === User::ROLE_PELANGGAN && $user->customer?->id !== $meterReading->customer_id;
    }
}
