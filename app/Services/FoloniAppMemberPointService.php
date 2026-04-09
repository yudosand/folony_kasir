<?php

namespace App\Services;

use Illuminate\Support\Arr;
use RuntimeException;

class FoloniAppMemberPointService
{
    public const TYPE_ADD = '1';
    public const TYPE_SUBTRACT = '2';

    public function __construct(
        private readonly FoloniAppAdminAuthService $foloniAppAdminAuthService,
    ) {
    }

    public function lookupMembers(array $filters = []): array
    {
        $memberPointsUrl = (string) config('services.foloni_app_admin.member_points_url');

        if ($memberPointsUrl === '') {
            throw new RuntimeException('URL member points Foloni App belum dikonfigurasi.');
        }

        $query = [];

        if (filled($filters['member_id'] ?? null)) {
            $query['id'] = (int) $filters['member_id'];
        }

        $response = $this->foloniAppAdminAuthService->authorizedGet($memberPointsUrl, $query);

        if (! $response->ok()) {
            throw new RuntimeException('Data member Foloni App belum berhasil dimuat. Coba lagi ya.');
        }

        $body = $response->json();

        if (! is_array($body) || (int) ($body['status_code'] ?? 0) !== 1) {
            throw new RuntimeException('Data member Foloni App belum berhasil dimuat. Coba lagi ya.');
        }

        $data = Arr::get($body, 'result.data', []);
        $members = collect(is_array($data) ? $data : [])
            ->map(fn (array $member): array => [
                'id' => (int) ($member['id'] ?? 0),
                'name' => (string) ($member['name'] ?? ''),
                'points' => (int) ($member['poin'] ?? 0),
            ])
            ->filter(fn (array $member): bool => $member['id'] > 0 && $member['name'] !== '')
            ->values()
            ->all();

        return [
            'members' => $members,
            'total_records' => (int) Arr::get($body, 'result.totalrecords', count($members)),
        ];
    }

    public function findMemberById(int $memberId): ?array
    {
        $lookup = $this->lookupMembers([
            'member_id' => $memberId,
        ]);

        return collect($lookup['members'])
            ->firstWhere('id', $memberId);
    }

    public function lookupPointHistory(array $filters = []): array
    {
        $historyUrl = (string) config('services.foloni_app_admin.point_history_url');

        if ($historyUrl === '') {
            throw new RuntimeException('URL riwayat poin Foloni App belum dikonfigurasi.');
        }

        $query = [];

        if (filled($filters['member_id'] ?? null)) {
            $query['id'] = (int) $filters['member_id'];
        }

        $response = $this->foloniAppAdminAuthService->authorizedGet($historyUrl, $query);

        if (! $response->ok()) {
            throw new RuntimeException('Riwayat poin Foloni App belum berhasil dimuat. Coba lagi ya.');
        }

        $body = $response->json();

        if (! is_array($body) || (int) ($body['status_code'] ?? 0) !== 1) {
            throw new RuntimeException('Riwayat poin Foloni App belum berhasil dimuat. Coba lagi ya.');
        }

        $data = Arr::get($body, 'result.data', []);
        $history = collect(is_array($data) ? $data : [])
            ->map(fn (array $entry): array => [
                'member_id' => (int) ($entry['id'] ?? 0),
                'name' => (string) ($entry['name'] ?? ''),
                'type' => trim((string) ($entry['type'] ?? '')),
                'transaction_type' => trim((string) ($entry['transaction_type'] ?? '')),
                'description' => trim((string) ($entry['description'] ?? '')),
                'amount' => $this->normalizePointAmount($entry['amount'] ?? 0),
                'created_at' => (string) ($entry['created_at'] ?? ''),
                'created_by' => (string) ($entry['created_by'] ?? ''),
            ])
            ->filter(fn (array $entry): bool => $entry['member_id'] > 0)
            ->values()
            ->all();

        return [
            'entries' => $history,
            'total_records' => (int) Arr::get($body, 'result.totalrecords', count($history)),
        ];
    }

    public function findMatchingPointHistory(
        int $memberId,
        string $type,
        int $amount,
        string $description,
    ): ?array {
        $history = $this->lookupPointHistory([
            'member_id' => $memberId,
        ]);

        return collect($history['entries'])
            ->first(fn (array $entry): bool =>
                $entry['member_id'] === $memberId
                && strtolower($entry['type']) === strtolower($type)
                && $entry['amount'] === $amount
                && $entry['description'] === $description
            );
    }

    public function mutatePoints(array $payload): array
    {
        $pointMutationUrl = (string) config('services.foloni_app_admin.point_mutation_url');

        if ($pointMutationUrl === '') {
            throw new RuntimeException('URL mutasi poin Foloni App belum dikonfigurasi.');
        }

        $requestPayload = [
            'user_ids' => [(int) $payload['member_id']],
            'type' => (string) $payload['type'],
            'description' => (string) $payload['description'],
            'amount' => (string) ((int) $payload['amount']),
        ];

        $response = $this->foloniAppAdminAuthService->authorizedPost($pointMutationUrl, $requestPayload);

        if (! $response->ok()) {
            throw new RuntimeException('Mutasi poin member belum berhasil. Coba lagi ya.');
        }

        $body = $response->json();

        if (! is_array($body)) {
            throw new RuntimeException('Respons mutasi poin Foloni App tidak valid. Coba lagi ya.');
        }

        $statusCode = (int) ($body['status_code'] ?? $body['statusCode'] ?? 0);

        if ($statusCode !== 1) {
            $message = trim((string) ($body['message'] ?? 'Mutasi poin member belum berhasil. Coba lagi ya.'));
            throw new RuntimeException($message !== '' ? $message : 'Mutasi poin member belum berhasil. Coba lagi ya.');
        }

        return [
            'message' => trim((string) ($body['message'] ?? 'Mutasi poin member berhasil.')),
            'raw' => $body,
            'member_id' => (int) $payload['member_id'],
            'type' => (string) $payload['type'],
            'amount' => (int) $payload['amount'],
            'description' => (string) $payload['description'],
        ];
    }

    private function normalizePointAmount(mixed $amount): int
    {
        if (is_int($amount)) {
            return $amount;
        }

        if (is_float($amount)) {
            return (int) round($amount);
        }

        if (is_string($amount)) {
            $digits = preg_replace('/[^0-9]/', '', $amount);

            return $digits === null || $digits === ''
                ? 0
                : (int) $digits;
        }

        return (int) $amount;
    }
}
