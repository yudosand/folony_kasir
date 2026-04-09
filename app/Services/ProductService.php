<?php

namespace App\Services;

use App\Models\Product;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Pagination\LengthAwarePaginator;
use Throwable;

class ProductService
{
    public function __construct(
        private readonly ImageStorageService $imageStorageService,
    ) {
    }

    public function paginateForUser(User $user, array $filters): LengthAwarePaginator
    {
        $perPage = max(1, min((int) ($filters['per_page'] ?? 10), 100));

        return Product::query()
            ->ownedBy($user)
            ->when(
                filled($filters['search'] ?? null),
                fn ($query) => $query->where('name', 'like', '%'.$filters['search'].'%')
            )
            ->latest('id')
            ->paginate($perPage)
            ->withQueryString();
    }

    public function findOwnedByUserOrFail(User $user, int $productId): Product
    {
        return Product::query()
            ->ownedBy($user)
            ->findOrFail($productId);
    }

    public function createForUser(User $user, array $payload): Product
    {
        $newImagePath = null;

        if (($payload['image'] ?? null) instanceof UploadedFile) {
            $newImagePath = $this->imageStorageService->store(
                $payload['image'],
                config('folony.product_image_directory'),
            );
            $payload['image_path'] = $newImagePath;
        }

        unset($payload['image'], $payload['remove_image']);

        try {
            return $user->products()->create($payload);
        } catch (Throwable $exception) {
            $this->imageStorageService->delete($newImagePath);

            throw $exception;
        }
    }

    public function update(Product $product, array $payload): Product
    {
        $oldImagePath = $product->image_path;
        $newImagePath = null;
        $shouldRemoveCurrentImage = (bool) ($payload['remove_image'] ?? false);

        if ($shouldRemoveCurrentImage) {
            $payload['image_path'] = null;
        }

        if (($payload['image'] ?? null) instanceof UploadedFile) {
            $newImagePath = $this->imageStorageService->store(
                $payload['image'],
                config('folony.product_image_directory'),
            );
            $payload['image_path'] = $newImagePath;
        }

        unset($payload['image'], $payload['remove_image']);

        try {
            $product->update($payload);
        } catch (Throwable $exception) {
            $this->imageStorageService->delete($newImagePath);

            throw $exception;
        }

        // Remove the previous file only after the database update succeeds,
        // so a failed write does not leave the record pointing at a missing asset.
        if (($shouldRemoveCurrentImage || $newImagePath !== null) && $oldImagePath) {
            $this->imageStorageService->delete($oldImagePath);
        }

        return $product->refresh();
    }

    public function delete(Product $product): void
    {
        $this->imageStorageService->delete($product->image_path);
        $product->delete();
    }
}
