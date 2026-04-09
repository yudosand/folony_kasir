<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Transaction\ListTransactionsRequest;
use App\Http\Requests\Transaction\StoreTransactionRequest;
use App\Http\Resources\InvoiceResource;
use App\Http\Resources\TransactionDetailResource;
use App\Http\Resources\TransactionResource;
use App\Services\TransactionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class TransactionController extends ApiController
{
    public function __construct(
        private readonly TransactionService $transactionService,
    ) {
    }

    public function index(ListTransactionsRequest $request): JsonResponse
    {
        $transactions = $this->transactionService->paginateForUser($request->user(), $request->validated());

        return $this->paginatedResponse(
            paginator: $transactions,
            message: 'Transactions retrieved successfully.',
            collectionKey: 'transactions',
            resourceClass: TransactionResource::class,
        );
    }

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        try {
            $transaction = $this->transactionService->create($request->user(), $request->validated());
        } catch (RuntimeException $exception) {
            return $this->errorResponse($exception->getMessage(), [], 503);
        }

        return $this->successResponse('Transaction saved successfully.', [
            'transaction' => (new TransactionDetailResource($transaction))->resolve(),
        ], 201);
    }

    public function show(Request $request, int $transaction): JsonResponse
    {
        $transactionModel = $this->transactionService->findOwnedByUserOrFail($request->user(), $transaction);

        return $this->successResponse('Transaction retrieved successfully.', [
            'transaction' => (new TransactionDetailResource($transactionModel))->resolve(),
        ]);
    }

    public function invoice(Request $request, int $transaction): JsonResponse
    {
        $transactionModel = $this->transactionService->findOwnedByUserOrFail($request->user(), $transaction);

        return $this->successResponse('Invoice payload retrieved successfully.', [
            'invoice' => (new InvoiceResource($transactionModel))->resolve(),
        ]);
    }
}
