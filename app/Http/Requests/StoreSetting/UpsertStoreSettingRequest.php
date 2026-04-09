<?php

namespace App\Http\Requests\StoreSetting;

use App\Http\Requests\ApiFormRequest;

class UpsertStoreSettingRequest extends ApiFormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'remove_logo' => $this->boolean('remove_logo'),
        ]);
    }

    public function rules(): array
    {
        return [
            'store_name' => ['required', 'string', 'max:255'],
            'store_address' => ['nullable', 'string', 'max:1000'],
            'phone_number' => ['nullable', 'string', 'max:50'],
            'invoice_footer' => ['nullable', 'string', 'max:1000'],
            'logo' => ['nullable', 'image', 'max:5120'],
            'remove_logo' => ['nullable', 'boolean'],
        ];
    }
}
