<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'is_manual' => $this->product_id === null,
            'quantity' => (int) $this->quantity,
            'product_name_snapshot' => $this->product_name_snapshot,
            'cost_price_snapshot' => (float) $this->cost_price_snapshot,
            'selling_price_snapshot' => (float) $this->selling_price_snapshot,
            'line_subtotal' => (float) $this->line_subtotal,
        ];
    }
}
