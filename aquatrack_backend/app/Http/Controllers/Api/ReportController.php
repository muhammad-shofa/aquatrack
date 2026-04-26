<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly ReportService $reportService)
    {
    }

    public function usageHistory(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'customer_id' => ['nullable', 'exists:customers,id'],
            'period_year' => ['nullable', 'integer', 'between:2000,2100'],
        ]);

        return $this->successResponse($this->reportService->usageHistory($payload), 'Usage history report.');
    }

    public function arrears(): JsonResponse
    {
        return $this->successResponse($this->reportService->arrearsReport(), 'Arrears report.');
    }

    public function export(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'format' => ['required', 'in:excel,pdf'],
        ]);

        return $this->successResponse($this->reportService->exportPlaceholder($payload['format']), 'Export queued.');
    }
}
