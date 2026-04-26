<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly DashboardService $dashboardService)
    {
    }

    public function admin(): JsonResponse
    {
        return $this->successResponse($this->dashboardService->adminStats(), 'Admin dashboard stats.');
    }

    public function collector(Request $request): JsonResponse
    {
        return $this->successResponse($this->dashboardService->collectorStats($request->user()), 'Collector dashboard stats.');
    }
}
