<?php

namespace App\Http\Resources;

use BackedEnum;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'invoice_number' => $this->invoice_number,
            'payment_method' => $this->enumValue($this->payment_method),
            'payment_status' => $this->enumValue($this->payment_status),
            'item_count' => (int) $this->item_count,
            'member_points_used' => (int) $this->member_points_used,
            'member_points_value_amount' => (float) $this->member_points_value_amount,
            'grand_total' => (float) $this->grand_total,
            'amount_paid' => (float) $this->amount_paid,
            'change_amount' => (float) $this->change_amount,
            'due_amount' => (float) $this->due_amount,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }

    private function enumValue(mixed $value): mixed
    {
        return $value instanceof BackedEnum ? $value->value : $value;
    }
}
