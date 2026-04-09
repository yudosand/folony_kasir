<?php

namespace App\Enums;

enum PaymentMethod: string
{
    case CASH = 'cash';
    case NON_CASH = 'non_cash';
    case SPLIT = 'split';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
