<?php

namespace App\Http\Requests\Transaction;

use App\Enums\PaymentMethod;
use App\Http\Requests\ApiFormRequest;
use Illuminate\Validation\Rule;

class StoreTransactionRequest extends ApiFormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'cash_amount' => $this->input('cash_amount', 0),
            'non_cash_amount' => $this->input('non_cash_amount', 0),
        ]);
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*' => ['required', 'array'],
            'items.*.product_id' => ['nullable', 'integer'],
            'items.*.product_name' => ['nullable', 'string', 'max:255'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.unit_price' => ['nullable', 'numeric', 'min:0'],
            'member_id' => ['nullable', 'integer', 'min:1'],
            'points_used' => ['nullable', 'integer', 'min:1'],
            'payment_method' => ['required', Rule::in(PaymentMethod::values())],
            'cash_amount' => ['nullable', 'numeric', 'min:0'],
            'non_cash_amount' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            foreach ($this->input('items', []) as $index => $item) {
                $hasProductId = filled($item['product_id'] ?? null);
                $hasManualName = filled($item['product_name'] ?? null);
                $hasUnitPrice = array_key_exists('unit_price', $item)
                    && $item['unit_price'] !== null
                    && $item['unit_price'] !== '';

                if (! $hasProductId && ! $hasManualName) {
                    $validator->errors()->add(
                        "items.$index.product_name",
                        'Product name is required for manual items.'
                    );
                }

                if (! $hasProductId && ! $hasUnitPrice) {
                    $validator->errors()->add(
                        "items.$index.unit_price",
                        'Unit price is required for manual items.'
                    );
                }
            }

            $hasMemberId = filled($this->input('member_id'));
            $hasPointsUsed = filled($this->input('points_used'));

            if ($hasMemberId && ! $hasPointsUsed) {
                $validator->errors()->add('points_used', 'Jumlah poin yang digunakan wajib diisi ya.');
            }

            if ($hasPointsUsed && ! $hasMemberId) {
                $validator->errors()->add('member_id', 'Member wajib dipilih dulu ya.');
            }
        });
    }
}
