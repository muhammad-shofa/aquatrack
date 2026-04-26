<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BillController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MeterReadingController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\TariffController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::get('/me/customer-profile', [CustomerController::class, 'myProfile'])->middleware('role:pelanggan');

        Route::apiResource('meter-readings', MeterReadingController::class)->except('destroy');
        Route::apiResource('bills', BillController::class)->only(['index', 'show']);
        Route::post('/bills/{bill}/apply-penalty', [BillController::class, 'applyPenalty'])->middleware('role:admin');
        Route::get('/arrears', [BillController::class, 'arrears'])->middleware('role:admin,penagih');

        Route::apiResource('payments', PaymentController::class)->only(['index', 'store', 'show']);
        Route::post('/payments/{payment}/verify', [PaymentController::class, 'verify'])->middleware('role:admin');

        Route::get('/dashboard/admin', [DashboardController::class, 'admin'])->middleware('role:admin');
        Route::get('/dashboard/collector', [DashboardController::class, 'collector'])->middleware('role:penagih');

        Route::get('/reports/usage-history', [ReportController::class, 'usageHistory'])->middleware('role:admin,penagih');
        Route::get('/reports/arrears', [ReportController::class, 'arrears'])->middleware('role:admin');
        Route::post('/reports/export', [ReportController::class, 'export'])->middleware('role:admin');

        Route::post('/notifications/bills/{bill}/alert', [NotificationController::class, 'billAlert'])->middleware('role:admin,penagih');
        Route::post('/notifications/bills/{bill}/reminder', [NotificationController::class, 'dueReminder'])->middleware('role:admin,penagih');

        Route::apiResource('customers', CustomerController::class)->middleware('role:admin');
        Route::apiResource('tariffs', TariffController::class)->middleware('role:admin');
    });
});
