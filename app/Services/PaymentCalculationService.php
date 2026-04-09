<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;

class PaymentCalculationService
{
    public function calculate(
        string $paymentMethod,
        float $grandTotal,
        float $cashAmount = 0,
        float $nonCashAmount = 0,
    ): array {
        $method = PaymentMethod::from($paymentMethod);

        $cashAmount = round($cashAmount, 2);
        $nonCashAmount = round($nonCashAmount, 2);
        $grandTotal = round($grandTotal, 2);

        [$normalizedCashAmount, $normalizedNonCashAmount, $amountPaid] = match ($method) {
            PaymentMethod::CASH => [$cashAmount, 0.0, $cashAmount],
            PaymentMethod::NON_CASH => [0.0, $nonCashAmount, $nonCashAmount],
            PaymentMethod::SPLIT => [$cashAmount, $nonCashAmount, round($cashAmount + $nonCashAmount, 2)],
        };

        $dueAmount = (float) max(round($grandTotal - $amountPaid, 2), 0);
        $changeAmount = $method === PaymentMethod::NON_CASH
            ? 0.0
            : (float) max(round($amountPaid - $grandTotal, 2), 0);

        return [
            'cash_amount' => $normalizedCashAmount,
            'non_cash_amount' => $normalizedNonCashAmount,
            'amount_paid' => $amountPaid,
            'due_amount' => $dueAmount,
            'change_amount' => $changeAmount,
            'payment_status' => $dueAmount > 0 ? PaymentStatus::PARTIAL->value : PaymentStatus::PAID->value,
        ];
    }
}
