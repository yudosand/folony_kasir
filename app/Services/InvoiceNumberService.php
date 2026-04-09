<?php

namespace App\Services;

use App\Models\Transaction;
use Carbon\Carbon;

class InvoiceNumberService
{
    public function generate(): string
    {
        $prefix = 'INV'.Carbon::now()->format('Ymd');

        // The query runs inside the transaction write flow so concurrent checkouts
        // queue behind the same date prefix and do not reissue the same number.
        $latestInvoiceNumber = Transaction::query()
            ->where('invoice_number', 'like', $prefix.'%')
            ->lockForUpdate()
            ->latest('id')
            ->value('invoice_number');

        $nextSequence = $latestInvoiceNumber
            ? ((int) substr($latestInvoiceNumber, -4)) + 1
            : 1;

        return sprintf('%s%04d', $prefix, $nextSequence);
    }
}
