<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ImageStorageService
{
    public function store(UploadedFile $file, string $directory): string
    {
        return $file->store($directory, $this->disk());
    }

    public function delete(?string $path): void
    {
        if (! $path) {
            return;
        }

        Storage::disk($this->disk())->delete($path);
    }

    public function url(?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        return Storage::disk($this->disk())->url($path);
    }

    private function disk(): string
    {
        return config('folony.image_disk');
    }
}
