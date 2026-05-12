<?php

namespace App\Http\Requests\Stock;

use App\Http\Requests\ApiFormRequest;

class StoreStockRestockRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'quantity' => ['required', 'integer', 'min:1'],
            'unit_cost' => ['nullable', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string', 'max:255'],
        ];
    }
}
