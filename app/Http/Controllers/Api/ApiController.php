<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use stdClass;
use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\LengthAwarePaginator;

class ApiController extends Controller
{
    protected function successResponse(string $message, mixed $data = null, int $status = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data ?? new stdClass(),
        ], $status);
    }

    protected function errorResponse(string $message, array $errors = [], int $status = 422): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors ?: new stdClass(),
        ], $status);
    }

    protected function paginatedResponse(
        LengthAwarePaginator $paginator,
        string $message,
        string $collectionKey,
        string $resourceClass,
    ): JsonResponse {
        return $this->successResponse($message, [
            $collectionKey => $resourceClass::collection($paginator->getCollection())->resolve(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }
}
