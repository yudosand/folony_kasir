<?php

namespace App\Http\Requests\Product;

use App\Http\Requests\ApiFormRequest;

class StoreProductRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'stock' => ['required', 'integer', 'min:0'],
            'cost_price' => ['required', 'numeric', 'min:0'],
            'selling_price' => ['required', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:5120'],
        ];
    }
}
