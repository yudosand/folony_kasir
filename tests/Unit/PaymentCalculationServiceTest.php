<?php

namespace Tests\Unit;

use App\Services\PaymentCalculationService;
use PHPUnit\Framework\TestCase;

class PaymentCalculationServiceTest extends TestCase
{
    public function test_cash_payment_calculates_change(): void
    {
        $service = new PaymentCalculationService();

        $result = $service->calculate('cash', 3500, 5000, 9000);

        $this->assertSame(5000.0, $result['cash_amount']);
        $this->assertSame(0.0, $result['non_cash_amount']);
        $this->assertSame(5000.0, $result['amount_paid']);
        $this->assertSame(1500.0, $result['change_amount']);
        $this->assertSame(0.0, $result['due_amount']);
        $this->assertSame('paid', $result['payment_status']);
    }

    public function test_non_cash_underpayment_becomes_partial_without_change(): void
    {
        $service = new PaymentCalculationService();

        $result = $service->calculate('non_cash', 3500, 7000, 2000);

        $this->assertSame(0.0, $result['cash_amount']);
        $this->assertSame(2000.0, $result['non_cash_amount']);
        $this->assertSame(2000.0, $result['amount_paid']);
        $this->assertSame(0.0, $result['change_amount']);
        $this->assertSame(1500.0, $result['due_amount']);
        $this->assertSame('partial', $result['payment_status']);
    }

    public function test_split_payment_combines_amounts_and_tracks_due(): void
    {
        $service = new PaymentCalculationService();

        $result = $service->calculate('split', 10000, 2500, 3000);

        $this->assertSame(2500.0, $result['cash_amount']);
        $this->assertSame(3000.0, $result['non_cash_amount']);
        $this->assertSame(5500.0, $result['amount_paid']);
        $this->assertSame(0.0, $result['change_amount']);
        $this->assertSame(4500.0, $result['due_amount']);
        $this->assertSame('partial', $result['payment_status']);
    }
}
