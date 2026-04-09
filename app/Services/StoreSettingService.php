<?php

namespace App\Services;

use App\Models\StoreSetting;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Throwable;

class StoreSettingService
{
    public function __construct(
        private readonly ImageStorageService $imageStorageService,
    ) {
    }

    public function getForUser(User $user): ?StoreSetting
    {
        return $user->storeSetting()->first();
    }

    public function upsertForUser(User $user, array $payload): StoreSetting
    {
        $storeSetting = $user->storeSetting()->firstOrNew();
        $oldLogoPath = $storeSetting->logo_path;
        $newLogoPath = null;
        $shouldRemoveCurrentLogo = (bool) ($payload['remove_logo'] ?? false);

        if ($shouldRemoveCurrentLogo) {
            $payload['logo_path'] = null;
        }

        if (($payload['logo'] ?? null) instanceof UploadedFile) {
            $newLogoPath = $this->imageStorageService->store(
                $payload['logo'],
                config('folony.store_logo_directory'),
            );
            $payload['logo_path'] = $newLogoPath;
        }

        unset($payload['logo'], $payload['remove_logo']);

        try {
            $storeSetting->fill($payload);
            $storeSetting->user()->associate($user);
            $storeSetting->save();
        } catch (Throwable $exception) {
            $this->imageStorageService->delete($newLogoPath);

            throw $exception;
        }

        // Defer deleting the previous asset until persistence succeeds so the
        // store record never ends up referencing a file that was already removed.
        if (($shouldRemoveCurrentLogo || $newLogoPath !== null) && $oldLogoPath) {
            $this->imageStorageService->delete($oldLogoPath);
        }

        return $storeSetting->refresh();
    }
}
