<?php

namespace App\Http\Requests\Product;

use App\Http\Requests\ApiFormRequest;

class ListProductsRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'search' => ['nullable', 'string', 'max:255'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }
}
