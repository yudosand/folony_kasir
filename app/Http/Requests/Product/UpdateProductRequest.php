<?php

namespace App\Http\Requests\Product;

use App\Http\Requests\ApiFormRequest;

class UpdateProductRequest extends ApiFormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'remove_image' => $this->boolean('remove_image'),
        ]);
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'stock' => ['sometimes', 'required', 'integer', 'min:0'],
            'cost_price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'selling_price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'image' => ['nullable', 'image', 'max:5120'],
            'remove_image' => ['nullable', 'boolean'],
        ];
    }
}
