<?php

namespace App\Support;

class MemberPointStatusPresenter
{
    public static function normalize(?string $status): string
    {
        $normalized = strtolower(trim((string) $status));

        return match ($normalized) {
            'deducated', 'dedicated' => 'deducted',
            '' => 'unknown',
            default => $normalized,
        };
    }

    public static function label(?string $status): string
    {
        return match (self::normalize($status)) {
            'deducted' => 'Poin terpotong',
            'verified' => 'Terkonfirmasi',
            'history_verified' => 'Terkonfirmasi via riwayat',
            'pending' => 'Menunggu sinkronisasi',
            'failed' => 'Gagal sinkronisasi',
            'none' => 'Tidak memakai poin',
            default => 'Status belum diketahui',
        };
    }

    public static function badgeClass(?string $status): string
    {
        return match (self::normalize($status)) {
            'deducted', 'verified', 'history_verified' => 'badge--success',
            'failed' => 'badge--danger',
            default => 'badge--warning',
        };
    }
}
