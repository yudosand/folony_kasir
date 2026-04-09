<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'product_id' => $this->product_id,
            'is_manual' => $this->product_id === null,
            'product_name' => $this->product_name_snapshot,
            'quantity' => (int) $this->quantity,
            'selling_price' => (float) $this->selling_price_snapshot,
            'line_subtotal' => (float) $this->line_subtotal,
        ];
    }
}
