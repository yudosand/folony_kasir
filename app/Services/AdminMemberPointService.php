<?php

namespace App\Services;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class AdminMemberPointService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return $this->baseQuery($filters)
            ->paginate(15)
            ->withQueryString();
    }

    public function exportRows(array $filters = []): Collection
    {
        return $this->baseQuery($filters)->get();
    }

    private function baseQuery(array $filters = []): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $status = trim((string) ($filters['status'] ?? ''));
        $dateFrom = trim((string) ($filters['date_from'] ?? ''));
        $dateTo = trim((string) ($filters['date_to'] ?? ''));

        return Transaction::query()
            ->with('user:id,name,phone,email')
            ->where('member_points_used', '>', 0)
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($builder) use ($search) {
                    $builder
                        ->where('invoice_number', 'like', "%{$search}%")
                        ->orWhere('member_name_snapshot', 'like', "%{$search}%")
                        ->orWhere('member_external_id', 'like', "%{$search}%")
                        ->orWhereHas('user', function ($userQuery) use ($search) {
                            $userQuery
                                ->where('name', 'like', "%{$search}%")
                                ->orWhere('phone', 'like', "%{$search}%")
                                ->orWhere('email', 'like', "%{$search}%");
                        });
                });
            })
            ->when($status !== '', fn ($query) => $query->where('member_point_status', $status))
            ->when($dateFrom !== '', fn ($query) => $query->whereDate('created_at', '>=', $dateFrom))
            ->when($dateTo !== '', fn ($query) => $query->whereDate('created_at', '<=', $dateTo))
            ->latest();
    }
}
