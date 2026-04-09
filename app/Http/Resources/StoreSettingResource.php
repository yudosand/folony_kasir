<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class StoreSettingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'store_name' => $this->store_name,
            'store_address' => $this->store_address,
            'phone_number' => $this->phone_number,
            'invoice_footer' => $this->invoice_footer,
            'logo_path' => $this->logo_path,
            'logo_url' => $this->logo_path
                ? Storage::disk(config('folony.image_disk'))->url($this->logo_path)
                : null,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
