<?php

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\InvoiceController;
use App\Http\Controllers\Admin\MemberPointController;
use App\Http\Controllers\Admin\ProductController;
use App\Http\Controllers\Admin\TransactionController;
use App\Http\Controllers\Admin\UserController;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return response()->json([
        'success' => true,
        'message' => 'Folony Kasir API is running.',
        'data' => [],
    ]);
});

Route::get('/storage/{path}', function (string $path) {
    // Laravel's built-in Windows server can fail to serve storage symlinks,
    // so this fallback keeps local Android image previews working in dev.
    $fullPath = Storage::disk(config('folony.image_disk'))->path($path);

    abort_unless(File::exists($fullPath), 404);

    return response()->file($fullPath);
})->where('path', '.*');

Route::redirect('/login', '/'.trim((string) config('admin-dashboard.path'), '/').'/login')->name('login');

Route::prefix(trim((string) config('admin-dashboard.path'), '/'))
    ->group(function (): void {
        Route::middleware('admin.dashboard.guest')->group(function (): void {
            Route::get('/login', [AuthController::class, 'create'])->name('admin.login');
            Route::post('/login', [AuthController::class, 'store'])->name('admin.login.store');
        });

        Route::middleware('admin.dashboard.auth')->group(function (): void {
            Route::get('/', [DashboardController::class, 'index'])->name('admin.dashboard');
            Route::post('/logout', [AuthController::class, 'destroy'])->name('admin.logout');
            Route::get('/users', [UserController::class, 'index'])->name('admin.users.index');
            Route::get('/users/export', [UserController::class, 'export'])->name('admin.users.export');
            Route::get('/users/{user}', [UserController::class, 'show'])->name('admin.users.show');
            Route::get('/invoices', [InvoiceController::class, 'index'])->name('admin.invoices.index');
            Route::get('/invoices/export', [InvoiceController::class, 'export'])->name('admin.invoices.export');
            Route::get('/invoices/{transaction}', [InvoiceController::class, 'show'])->name('admin.invoices.show');
            Route::get('/transactions', [TransactionController::class, 'index'])->name('admin.transactions.index');
            Route::get('/transactions/export', [TransactionController::class, 'export'])->name('admin.transactions.export');
            Route::get('/products', [ProductController::class, 'index'])->name('admin.products.index');
            Route::get('/products/export', [ProductController::class, 'export'])->name('admin.products.export');
            Route::get('/products/{product}', [ProductController::class, 'show'])->name('admin.products.show');
            Route::get('/member-points', [MemberPointController::class, 'index'])->name('admin.member-points.index');
            Route::get('/member-points/export', [MemberPointController::class, 'export'])->name('admin.member-points.export');
        });
    });
