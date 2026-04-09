<?php

namespace App\Http\Requests\MemberPoint;

use App\Http\Requests\ApiFormRequest;
use Illuminate\Validation\Rule;

class MutateMemberPointsRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'member_id' => ['required', 'integer', 'min:1'],
            'type' => ['required', Rule::in(['1', '2', 1, 2])],
            'amount' => ['required', 'integer', 'min:1'],
            'description' => ['required', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'member_id.required' => 'ID member wajib diisi ya.',
            'member_id.integer' => 'ID member belum valid ya.',
            'member_id.min' => 'ID member belum valid ya.',
            'type.required' => 'Tipe mutasi poin wajib diisi ya.',
            'type.in' => 'Tipe mutasi poin belum valid ya.',
            'amount.required' => 'Jumlah poin wajib diisi ya.',
            'amount.integer' => 'Jumlah poin harus berupa angka bulat ya.',
            'amount.min' => 'Jumlah poin minimal 1 ya.',
            'description.required' => 'Deskripsi mutasi poin wajib diisi ya.',
        ];
    }
}
