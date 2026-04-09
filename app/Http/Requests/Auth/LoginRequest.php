<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiFormRequest;

class LoginRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'phone' => ['required_without:email', 'string', 'max:30'],
            'email' => ['nullable', 'email'],
            'password' => ['required', 'string'],
            'fcm_token' => ['nullable', 'string'],
            'lat' => ['nullable', 'string', 'max:50'],
            'long' => ['nullable', 'string', 'max:50'],
            'id_device' => ['nullable', 'string', 'max:255'],
            'os_version' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.required_without' => 'Nomor HP wajib diisi ya.',
            'password.required' => 'Password wajib diisi ya.',
        ];
    }
}
