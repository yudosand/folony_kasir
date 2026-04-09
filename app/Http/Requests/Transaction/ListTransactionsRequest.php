<?php

namespace App\Http\Requests\Transaction;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Http\Requests\ApiFormRequest;
use Illuminate\Validation\Rule;

class ListTransactionsRequest extends ApiFormRequest
{
    public function rules(): array
    {
        return [
            'search' => ['nullable', 'string', 'max:255'],
            'payment_method' => ['nullable', Rule::in(PaymentMethod::values())],
            'payment_status' => ['nullable', Rule::in(array_column(PaymentStatus::cases(), 'value'))],
            'date_from' => ['nullable', 'date_format:Y-m-d'],
            'date_to' => ['nullable', 'date_format:Y-m-d', 'after_or_equal:date_from'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:100'],
        ];
    }
}
