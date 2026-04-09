<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class AuthController extends ApiController
{
    public function __construct(
        private readonly AuthService $authService,
    ) {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->register($request->validated());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), status: 503);
        }

        return $this->successResponse('Registration successful.', [
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => (new UserResource($result['user']))->resolve(),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->login($request->validated());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), status: 503);
        }

        return $this->successResponse('Login successful.', [
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => (new UserResource($result['user']))->resolve(),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return $this->successResponse('Logout successful.', null);
    }

    public function me(Request $request): JsonResponse
    {
        return $this->successResponse('Authenticated user retrieved successfully.', [
            'user' => (new UserResource($request->user()))->resolve(),
        ]);
    }
}
