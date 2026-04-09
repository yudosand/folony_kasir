<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Product\ListProductsRequest;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Services\ProductService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends ApiController
{
    public function __construct(
        private readonly ProductService $productService,
    ) {
    }

    public function index(ListProductsRequest $request): JsonResponse
    {
        $products = $this->productService->paginateForUser($request->user(), $request->validated());

        return $this->paginatedResponse(
            paginator: $products,
            message: 'Products retrieved successfully.',
            collectionKey: 'products',
            resourceClass: ProductResource::class,
        );
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $product = $this->productService->createForUser($request->user(), $request->validated());

        return $this->successResponse('Product created successfully.', [
            'product' => (new ProductResource($product))->resolve(),
        ], 201);
    }

    public function show(Request $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);

        return $this->successResponse('Product retrieved successfully.', [
            'product' => (new ProductResource($productModel))->resolve(),
        ]);
    }

    public function update(UpdateProductRequest $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);
        $productModel = $this->productService->update($productModel, $request->validated());

        return $this->successResponse('Product updated successfully.', [
            'product' => (new ProductResource($productModel))->resolve(),
        ]);
    }

    public function destroy(Request $request, int $product): JsonResponse
    {
        $productModel = $this->productService->findOwnedByUserOrFail($request->user(), $product);
        $this->productService->delete($productModel);

        return $this->successResponse('Product deleted successfully.', null);
    }
}
