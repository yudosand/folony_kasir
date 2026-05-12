<?php

namespace App\Http\Resources;

use App\Support\StockStatusPresenter;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $status = StockStatusPresenter::resolve((int) $this->stock, (int) $this->minimum_stock);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'stock' => (int) $this->stock,
            'minimum_stock' => (int) $this->minimum_stock,
            'stock_status' => $status['code'],
            'stock_status_label' => $status['label'],
            'needs_restock' => $status['needs_restock'],
            'cost_price' => (float) $this->cost_price,
            'selling_price' => (float) $this->selling_price,
            'image_path' => $this->image_path,
            'image_url' => $this->image_path
                ? Storage::disk(config('folony.image_disk'))->url($this->image_path)
                : null,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
