<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Report\ListSalesProfitReportRequest;
use App\Services\SalesProfitReportService;
use Illuminate\Http\JsonResponse;

class SalesProfitReportController extends ApiController
{
    public function __construct(
        private readonly SalesProfitReportService $salesProfitReportService,
    ) {
    }

    public function report(ListSalesProfitReportRequest $request): JsonResponse
    {
        $report = $this->salesProfitReportService->reportForUser(
            $request->user(),
            $request->validated(),
        );

        return $this->successResponse(
            'Sales profit report retrieved successfully.',
            $report,
        );
    }
}
