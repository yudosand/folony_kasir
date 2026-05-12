<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Stock\ListStockBookkeepingRequest;
use App\Http\Requests\Stock\StoreStockAdjustmentRequest;
use App\Http\Requests\Stock\StoreStockRestockRequest;
use App\Http\Resources\ProductResource;
use App\Services\ProductService;
use App\Services\StockBookkeepingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StockBookkeepingController extends ApiController
{
    public function __construct(
        private readonly StockBookkeepingService $stockBookkeepingService,
        private readonly ProductService $productService,
    ) {
    }

    public function index(ListStockBookkeepingRequest $request): JsonResponse
    {
        $paginator = $this->stockBookkeepingService->paginateForUser(
            $request->user(),
            $request->validated(),
        );

        return $this->successResponse('Stock bookkeeping retrieved successfully.', [
            'products' => $paginator->items(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    public function report(ListStockBookkeepingRequest $request): JsonResponse
    {
        $report = $this->stockBookkeepingService->reportForUser(
            $request->user(),
            $request->validated(),
        );

        return $this->successResponse('Stock bookkeeping report retrieved successfully.', $report);
    }

    public function show(Request $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);
        $payload = $this->stockBookkeepingService->stockCardForUser($productModel, $request->only('date_from', 'date_to'));

        return $this->successResponse('Stock card retrieved successfully.', $payload);
    }

    public function restock(StoreStockRestockRequest $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);
        $updatedProduct = $this->stockBookkeepingService->restock($productModel, $request->validated());

        return $this->successResponse('Stock restock recorded successfully.', [
            'product' => (new ProductResource($updatedProduct))->resolve(),
            'stock_card' => $this->stockBookkeepingService->stockCardForUser($updatedProduct),
        ]);
    }

    public function adjust(StoreStockAdjustmentRequest $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);
        $updatedProduct = $this->stockBookkeepingService->adjust($productModel, $request->validated());

        return $this->successResponse('Stock adjustment recorded successfully.', [
            'product' => (new ProductResource($updatedProduct))->resolve(),
            'stock_card' => $this->stockBookkeepingService->stockCardForUser($updatedProduct),
        ]);
    }
}
