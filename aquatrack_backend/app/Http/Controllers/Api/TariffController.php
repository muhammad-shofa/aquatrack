<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Tariff\StoreTariffRequest;
use App\Http\Requests\Tariff\UpdateTariffRequest;
use App\Http\Resources\TariffResource;
use App\Models\Tariff;
use App\Repositories\Contracts\TariffRepositoryInterface;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TariffController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly TariffRepositoryInterface $tariffRepository)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $tariffs = $this->tariffRepository->paginate((int) $request->integer('per_page', 15));

        return $this->successResponse(TariffResource::collection($tariffs), 'Tariff list.');
    }

    public function store(StoreTariffRequest $request): JsonResponse
    {
        $tariff = $this->tariffRepository->create($request->validated());

        return $this->successResponse(new TariffResource($tariff), 'Tariff created.', 201);
    }

    public function show(Tariff $tariff): JsonResponse
    {
        return $this->successResponse(new TariffResource($tariff), 'Tariff detail.');
    }

    public function update(UpdateTariffRequest $request, Tariff $tariff): JsonResponse
    {
        $updated = $this->tariffRepository->update($tariff, $request->validated());

        return $this->successResponse(new TariffResource($updated), 'Tariff updated.');
    }

    public function destroy(Tariff $tariff): JsonResponse
    {
        $this->tariffRepository->delete($tariff);

        return $this->successResponse(null, 'Tariff deleted.');
    }
}
