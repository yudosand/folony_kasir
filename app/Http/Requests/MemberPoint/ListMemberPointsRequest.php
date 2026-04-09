<?php

namespace App\Http\Requests\MemberPoint;

use App\Http\Requests\ApiFormRequest;

class ListMemberPointsRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'member_id' => ['nullable', 'integer', 'min:1'],
        ];
    }

    public function messages(): array
    {
        return [
            'member_id.integer' => 'ID member belum valid ya.',
            'member_id.min' => 'ID member belum valid ya.',
        ];
    }
}
