<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\StoreSetting\UpsertStoreSettingRequest;
use App\Http\Resources\StoreSettingResource;
use App\Services\StoreSettingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StoreSettingController extends ApiController
{
    public function __construct(
        private readonly StoreSettingService $storeSettingService,
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        $storeSetting = $this->storeSettingService->getForUser($request->user());

        return $this->successResponse('Store setting retrieved successfully.', [
            'store_setting' => $storeSetting
                ? (new StoreSettingResource($storeSetting))->resolve()
                : null,
        ]);
    }

    public function upsert(UpsertStoreSettingRequest $request): JsonResponse
    {
        $storeSetting = $this->storeSettingService->upsertForUser(
            $request->user(),
            $request->validated(),
        );

        return $this->successResponse('Store setting saved successfully.', [
            'store_setting' => (new StoreSettingResource($storeSetting))->resolve(),
        ]);
    }
}
