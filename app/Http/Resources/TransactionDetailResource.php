<?php

namespace App\Http\Resources;

use BackedEnum;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class TransactionDetailResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'invoice_number' => $this->invoice_number,
            'payment_method' => $this->enumValue($this->payment_method),
            'payment_status' => $this->enumValue($this->payment_status),
            'item_count' => (int) $this->item_count,
            'subtotal' => (float) $this->subtotal,
            'grand_total' => (float) $this->grand_total,
            'cash_amount' => (float) $this->cash_amount,
            'non_cash_amount' => (float) $this->non_cash_amount,
            'amount_paid' => (float) $this->amount_paid,
            'change_amount' => (float) $this->change_amount,
            'due_amount' => (float) $this->due_amount,
            'store' => [
                'name' => $this->store_name_snapshot,
                'address' => $this->store_address_snapshot,
                'phone_number' => $this->store_phone_snapshot,
                'logo_path' => $this->store_logo_path_snapshot,
                'logo_url' => $this->store_logo_path_snapshot
                    ? Storage::disk(config('folony.image_disk'))->url($this->store_logo_path_snapshot)
                    : null,
                'invoice_footer' => $this->invoice_footer_snapshot,
            ],
            'cashier' => [
                'name' => $this->cashier_name_snapshot,
                'email' => $this->cashier_email_snapshot,
            ],
            'member_points' => [
                'member_id' => $this->member_external_id,
                'member_name' => $this->member_name_snapshot,
                'points_before' => $this->member_points_before,
                'points_used' => (int) $this->member_points_used,
                'points_after' => $this->member_points_after,
                'value_amount' => (float) $this->member_points_value_amount,
                'status' => $this->member_point_status,
                'description' => $this->member_point_description,
            ],
            'items' => TransactionItemResource::collection($this->items)->resolve(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    private function enumValue(mixed $value): mixed
    {
        return $value instanceof BackedEnum ? $value->value : $value;
    }
}
