<?php

namespace App\Http\Requests\Stock;

use App\Http\Requests\ApiFormRequest;

class StoreStockAdjustmentRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'direction' => ['required', 'in:in,out'],
            'quantity' => ['required', 'integer', 'min:1'],
            'notes' => ['nullable', 'string', 'max:255'],
        ];
    }
}
