<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use App\Http\Middleware\EnsureAdminDashboardAuthenticated;
use App\Http\Middleware\RedirectIfAdminDashboardAuthenticated;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'admin.dashboard.auth' => EnsureAdminDashboardAuthenticated::class,
            'admin.dashboard.guest' => RedirectIfAdminDashboardAuthenticated::class,
        ]);

        $middleware->redirectGuestsTo(function (Request $request) {
            return $request->is('api/*') ? null : route('login');
        });
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $respondWithJson = static fn (Request $request): bool => $request->is('api/*');

        $exceptions->render(function (ValidationException $exception, Request $request) use ($respondWithJson) {
            if (! $respondWithJson($request)) {
                return null;
            }

            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $exception->errors(),
            ], $exception->status);
        });

        $exceptions->render(function (AuthenticationException $exception, Request $request) use ($respondWithJson) {
            if (! $respondWithJson($request)) {
                return null;
            }

            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
                'errors' => new \stdClass(),
            ], 401);
        });

        $exceptions->render(function (AuthorizationException $exception, Request $request) use ($respondWithJson) {
            if (! $respondWithJson($request)) {
                return null;
            }

            return response()->json([
                'success' => false,
                'message' => $exception->getMessage() ?: 'This action is unauthorized.',
                'errors' => new \stdClass(),
            ], 403);
        });

        $exceptions->render(function (ModelNotFoundException|NotFoundHttpException $exception, Request $request) use ($respondWithJson) {
            if (! $respondWithJson($request)) {
                return null;
            }

            return response()->json([
                'success' => false,
                'message' => 'Resource not found.',
                'errors' => new \stdClass(),
            ], 404);
        });

        $exceptions->render(function (\Throwable $exception, Request $request) use ($respondWithJson) {
            if (! $respondWithJson($request)) {
                return null;
            }

            Log::error('Unhandled API exception.', [
                'path' => $request->path(),
                'method' => $request->method(),
                'message' => $exception->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Server error.',
                'errors' => new \stdClass(),
            ], 500);
        });
    })->create();
