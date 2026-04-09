<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use RuntimeException;
use Illuminate\Validation\ValidationException;
use Throwable;

class TransactionService
{
    public function __construct(
        private readonly PaymentCalculationService $paymentCalculationService,
        private readonly InvoiceNumberService $invoiceNumberService,
        private readonly FoloniAppMemberPointService $foloniAppMemberPointService,
    ) {
    }

    public function paginateForUser(User $user, array $filters): LengthAwarePaginator
    {
        $perPage = max(1, min((int) ($filters['per_page'] ?? 10), 100));

        return Transaction::query()
            ->ownedBy($user)
            ->when(
                filled($filters['search'] ?? null),
                fn ($query) => $query->where('invoice_number', 'like', '%'.$filters['search'].'%')
            )
            ->when(
                filled($filters['payment_method'] ?? null),
                fn ($query) => $query->where('payment_method', $filters['payment_method'])
            )
            ->when(
                filled($filters['payment_status'] ?? null),
                fn ($query) => $query->where('payment_status', $filters['payment_status'])
            )
            ->when(
                filled($filters['date_from'] ?? null),
                fn ($query) => $query->whereDate('created_at', '>=', $filters['date_from'])
            )
            ->when(
                filled($filters['date_to'] ?? null),
                fn ($query) => $query->whereDate('created_at', '<=', $filters['date_to'])
            )
            ->latest('id')
            ->paginate($perPage)
            ->withQueryString();
    }

    public function findOwnedByUserOrFail(User $user, int $transactionId): Transaction
    {
        return Transaction::query()
            ->ownedBy($user)
            ->with('items')
            ->findOrFail($transactionId);
    }

    public function create(User $user, array $payload): Transaction
    {
        $maxAttempts = 3;
        $pointMutationContext = null;

        for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {
            try {
                return DB::transaction(function () use ($user, $payload, &$pointMutationContext) {
                    $itemsPayload = $payload['items'];
                    $productIds = collect($itemsPayload)
                        ->filter(fn (array $item) => filled($item['product_id'] ?? null))
                        ->pluck('product_id')
                        ->unique()
                        ->values()
                        ->all();

                    // Lock the owned product rows before stock checks so two checkouts
                    // cannot both consume the same stock at the same time.
                    $products = Product::query()
                        ->ownedBy($user)
                        ->whereIn('id', $productIds)
                        ->lockForUpdate()
                        ->get()
                        ->keyBy('id');

                    if ($products->count() !== count($productIds)) {
                        throw ValidationException::withMessages([
                            'items' => ['One or more selected products are invalid.'],
                        ]);
                    }

                    $preparedItems = [];
                    $subtotal = 0.0;
                    $itemCount = 0;

                    foreach ($itemsPayload as $index => $itemPayload) {
                        $quantity = (int) $itemPayload['quantity'];
                        $hasProductId = filled($itemPayload['product_id'] ?? null);

                        if ($hasProductId) {
                            /** @var Product|null $product */
                            $product = $products->get($itemPayload['product_id']);
                            if (! $product) {
                                throw ValidationException::withMessages([
                                    "items.$index.product_id" => ['Selected product is invalid.'],
                                ]);
                            }

                            if ($product->stock < $quantity) {
                                throw ValidationException::withMessages([
                                    "items.$index.quantity" => ["Insufficient stock for {$product->name}."],
                                ]);
                            }

                            $sellingPrice = (float) $product->selling_price;
                            $lineSubtotal = round($sellingPrice * $quantity, 2);
                            $preparedItems[] = [
                                'product' => $product,
                                'product_id' => $product->id,
                                'quantity' => $quantity,
                                'product_name_snapshot' => $product->name,
                                'cost_price_snapshot' => (float) $product->cost_price,
                                'selling_price_snapshot' => $sellingPrice,
                                'line_subtotal' => $lineSubtotal,
                                'is_manual' => false,
                            ];
                        } else {
                            $productName = trim((string) ($itemPayload['product_name'] ?? ''));
                            $unitPrice = round((float) ($itemPayload['unit_price'] ?? 0), 2);

                            if ($productName === '') {
                                throw ValidationException::withMessages([
                                    "items.$index.product_name" => ['Product name is required for manual items.'],
                                ]);
                            }

                            $lineSubtotal = round($unitPrice * $quantity, 2);
                            $preparedItems[] = [
                                'product' => null,
                                'product_id' => null,
                                'quantity' => $quantity,
                                'product_name_snapshot' => $productName,
                                'cost_price_snapshot' => $unitPrice,
                                'selling_price_snapshot' => $unitPrice,
                                'line_subtotal' => $lineSubtotal,
                                'is_manual' => true,
                            ];
                        }

                        $subtotal += $lineSubtotal;
                        $itemCount += $quantity;
                    }

                    $memberPointSnapshot = $this->prepareMemberPointSnapshot($payload, $subtotal);
                    $invoiceNumber = $this->invoiceNumberService->generate();

                    if ($memberPointSnapshot['used'] > 0) {
                        $description = sprintf('Potong poin invoice %s', $invoiceNumber);
                        $mutation = $this->foloniAppMemberPointService->mutatePoints([
                            'member_id' => $memberPointSnapshot['member_id'],
                            'type' => FoloniAppMemberPointService::TYPE_SUBTRACT,
                            'amount' => $memberPointSnapshot['used'],
                            'description' => $description,
                        ]);
                        $verification = $this->confirmMemberPointDeduction(
                            $memberPointSnapshot,
                            $description,
                        );

                        $memberPointSnapshot['status'] = 'deducted';
                        $memberPointSnapshot['description'] = $description;
                        $memberPointSnapshot['mutation_payload'] = array_merge($mutation['raw'], [
                            'verification' => [
                                'method' => $verification['method'],
                                'confirmed_at' => now()->toIso8601String(),
                            ],
                        ]);
                        $memberPointSnapshot['after'] = $verification['after'];
                        $pointMutationContext = [
                            'member_id' => $memberPointSnapshot['member_id'],
                            'amount' => $memberPointSnapshot['used'],
                            'invoice_number' => $invoiceNumber,
                            'deducted' => true,
                            'verified' => true,
                        ];
                    }

                    $grandTotal = round(max($subtotal - $memberPointSnapshot['value_amount'], 0), 2);

                    $paymentSummary = $this->paymentCalculationService->calculate(
                        paymentMethod: $payload['payment_method'],
                        grandTotal: $grandTotal,
                        cashAmount: (float) ($payload['cash_amount'] ?? 0),
                        nonCashAmount: (float) ($payload['non_cash_amount'] ?? 0),
                    );

                    $storeSetting = $user->storeSetting()->first();

                    $transaction = Transaction::query()->create([
                        'user_id' => $user->id,
                        'invoice_number' => $invoiceNumber,
                        'store_name_snapshot' => $storeSetting?->store_name,
                        'store_address_snapshot' => $storeSetting?->store_address,
                        'store_phone_snapshot' => $storeSetting?->phone_number,
                        'store_logo_path_snapshot' => $storeSetting?->logo_path,
                        'invoice_footer_snapshot' => $storeSetting?->invoice_footer,
                        'cashier_name_snapshot' => $user->name,
                        'cashier_email_snapshot' => $user->email,
                        'member_external_id' => $memberPointSnapshot['member_id'],
                        'member_name_snapshot' => $memberPointSnapshot['member_name'],
                        'member_points_before' => $memberPointSnapshot['before'],
                        'member_points_used' => $memberPointSnapshot['used'],
                        'member_points_after' => $memberPointSnapshot['after'],
                        'member_points_value_amount' => $memberPointSnapshot['value_amount'],
                        'member_point_status' => $memberPointSnapshot['status'],
                        'member_point_description' => $memberPointSnapshot['description'],
                        'member_point_mutation_payload' => $memberPointSnapshot['mutation_payload'],
                        'item_count' => $itemCount,
                        'subtotal' => $subtotal,
                        'grand_total' => $grandTotal,
                        'payment_method' => $payload['payment_method'],
                        'payment_status' => $paymentSummary['payment_status'],
                        'cash_amount' => $paymentSummary['cash_amount'],
                        'non_cash_amount' => $paymentSummary['non_cash_amount'],
                        'amount_paid' => $paymentSummary['amount_paid'],
                        'change_amount' => $paymentSummary['change_amount'],
                        'due_amount' => $paymentSummary['due_amount'],
                    ]);

                    $transaction->items()->createMany(array_map(
                        fn (array $preparedItem) => [
                            'product_id' => $preparedItem['product_id'],
                            'quantity' => $preparedItem['quantity'],
                            'product_name_snapshot' => $preparedItem['product_name_snapshot'],
                            'cost_price_snapshot' => $preparedItem['cost_price_snapshot'],
                            'selling_price_snapshot' => $preparedItem['selling_price_snapshot'],
                            'line_subtotal' => $preparedItem['line_subtotal'],
                        ],
                        $preparedItems
                    ));

                    foreach ($preparedItems as $preparedItem) {
                        $product = $preparedItem['product'];
                        if (! $product) {
                            continue;
                        }
                        $product->stock -= $preparedItem['quantity'];
                        $product->save();
                    }

                    $pointMutationContext = null;

                    return $transaction->load('items');
                });
            } catch (QueryException $exception) {
                $this->attemptPointReversal($pointMutationContext);

                if ($attempt === $maxAttempts || ! $this->wasInvoiceNumberCollision($exception)) {
                    throw $exception;
                }
            } catch (Throwable $exception) {
                $this->attemptPointReversal($pointMutationContext);
                throw $exception;
            }
        }

        throw new RuntimeException('Transaction creation failed after retry attempts.');
    }

    private function wasInvoiceNumberCollision(QueryException $exception): bool
    {
        return (string) $exception->getCode() === '23000'
            && str_contains(strtolower($exception->getMessage()), 'invoice_number');
    }

    private function prepareMemberPointSnapshot(array $payload, float $subtotal): array
    {
        $memberId = filled($payload['member_id'] ?? null)
            ? (int) $payload['member_id']
            : null;
        $pointsUsed = (int) ($payload['points_used'] ?? 0);

        $snapshot = [
            'member_id' => $memberId,
            'member_name' => null,
            'before' => null,
            'used' => 0,
            'after' => null,
            'value_amount' => 0.0,
            'status' => 'none',
            'description' => null,
            'mutation_payload' => null,
        ];

        if (! $memberId || $pointsUsed <= 0) {
            return $snapshot;
        }

        $member = $this->foloniAppMemberPointService->findMemberById($memberId);

        if (! $member) {
            throw ValidationException::withMessages([
                'member_id' => ['Member belum ditemukan. Coba cek lagi ya.'],
            ]);
        }

        $pointsBefore = (int) ($member['points'] ?? 0);

        if ($pointsBefore < $pointsUsed) {
            throw ValidationException::withMessages([
                'points_used' => ['Poin member tidak cukup.'],
            ]);
        }

        if ($pointsUsed > (int) round($subtotal)) {
            throw ValidationException::withMessages([
                'points_used' => ['Poin yang digunakan tidak boleh melebihi total belanja.'],
            ]);
        }

        $snapshot['member_name'] = (string) ($member['name'] ?? '');
        $snapshot['before'] = $pointsBefore;
        $snapshot['used'] = $pointsUsed;
        $snapshot['after'] = $pointsBefore - $pointsUsed;
        $snapshot['value_amount'] = (float) $pointsUsed; // 1 poin = Rp1

        return $snapshot;
    }

    private function confirmMemberPointDeduction(array $memberPointSnapshot, string $description): array
    {
        $memberId = (int) ($memberPointSnapshot['member_id'] ?? 0);
        $expectedAfter = (int) ($memberPointSnapshot['after'] ?? 0);
        $used = (int) ($memberPointSnapshot['used'] ?? 0);

        for ($attempt = 1; $attempt <= 3; $attempt++) {
            $member = $this->foloniAppMemberPointService->findMemberById($memberId);

            if (is_array($member) && (int) ($member['points'] ?? -1) === $expectedAfter) {
                return [
                    'method' => 'member_balance',
                    'after' => (int) ($member['points'] ?? $expectedAfter),
                ];
            }

            $historyEntry = $this->foloniAppMemberPointService->findMatchingPointHistory(
                memberId: $memberId,
                type: 'Kurang',
                amount: $used,
                description: $description,
            );

            if (is_array($historyEntry)) {
                return [
                    'method' => 'point_history',
                    'after' => $expectedAfter,
                ];
            }

            if ($attempt < 3) {
                sleep(1);
            }
        }

        throw new RuntimeException(
            'Potongan poin di Foloni App belum terkonfirmasi. Transaksi dibatalkan agar saldo member tetap aman.',
        );
    }

    private function attemptPointReversal(?array &$pointMutationContext): void
    {
        if (
            ! is_array($pointMutationContext)
            || ! ($pointMutationContext['deducted'] ?? false)
            || ! ($pointMutationContext['verified'] ?? false)
        ) {
            return;
        }

        try {
            $this->foloniAppMemberPointService->mutatePoints([
                'member_id' => $pointMutationContext['member_id'],
                'type' => FoloniAppMemberPointService::TYPE_ADD,
                'amount' => $pointMutationContext['amount'],
                'description' => sprintf(
                    'Reversal poin invoice %s',
                    $pointMutationContext['invoice_number'] ?? 'unknown'
                ),
            ]);
        } catch (Throwable $exception) {
            report($exception);
        } finally {
            $pointMutationContext = null;
        }
    }
}
