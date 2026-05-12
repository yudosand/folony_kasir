<?php

namespace App\Support;

class StockStatusPresenter
{
    public static function resolve(int $stock, int $minimumStock): array
    {
        if ($stock <= 0) {
            return [
                'code' => 'out',
                'label' => 'Habis',
                'needs_restock' => true,
            ];
        }

        if ($stock <= $minimumStock) {
            return [
                'code' => 'low',
                'label' => 'Menipis',
                'needs_restock' => true,
            ];
        }

        return [
            'code' => 'healthy',
            'label' => 'Aman',
            'needs_restock' => false,
        ];
    }
}
