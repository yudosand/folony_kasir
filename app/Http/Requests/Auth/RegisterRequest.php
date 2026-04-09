<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiFormRequest;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\Rule;

class RegisterRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:30', Rule::unique('users', 'phone')],
            'password' => ['required', 'string', Password::min(6), 'confirmed'],
            'password_confirmation' => ['required', 'string'],
            'referal' => ['required', 'string', 'max:255'],
            'fcm_token' => ['nullable', 'string'],
            'id_device' => ['nullable', 'string', 'max:255'],
            'os_version' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama wajib diisi ya.',
            'phone.required' => 'Nomor HP wajib diisi ya.',
            'phone.unique' => 'Nomor HP ini sudah terdaftar. Coba login ya.',
            'password.required' => 'Password wajib diisi ya.',
            'password.min' => 'Password minimal 6 karakter ya.',
            'password.confirmed' => 'Konfirmasi password belum cocok, coba cek lagi ya.',
            'password_confirmation.required' => 'Konfirmasi password wajib diisi ya.',
            'referal.required' => 'Kode referal wajib diisi ya.',
        ];
    }
}
