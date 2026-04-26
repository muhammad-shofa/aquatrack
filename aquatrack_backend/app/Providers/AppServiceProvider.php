<?php

namespace App\Providers;

use App\Repositories\Contracts\BillRepositoryInterface;
use App\Repositories\Contracts\CustomerRepositoryInterface;
use App\Repositories\Contracts\MeterReadingRepositoryInterface;
use App\Repositories\Contracts\PaymentRepositoryInterface;
use App\Repositories\Contracts\TariffRepositoryInterface;
use App\Repositories\Eloquent\BillRepository;
use App\Repositories\Eloquent\CustomerRepository;
use App\Repositories\Eloquent\MeterReadingRepository;
use App\Repositories\Eloquent\PaymentRepository;
use App\Repositories\Eloquent\TariffRepository;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(CustomerRepositoryInterface::class, CustomerRepository::class);
        $this->app->bind(TariffRepositoryInterface::class, TariffRepository::class);
        $this->app->bind(MeterReadingRepositoryInterface::class, MeterReadingRepository::class);
        $this->app->bind(BillRepositoryInterface::class, BillRepository::class);
        $this->app->bind(PaymentRepositoryInterface::class, PaymentRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
