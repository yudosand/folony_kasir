@extends('admin.layouts.app')

@section('title', 'Member Points')

@section('content')
    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">Member Points</h1>
            <div class="admin-topbar__subtitle">
                Monitoring transaksi yang memakai poin member dan status sinkronisasinya ke Foloni App.
            </div>
        </div>
        <a href="{{ route('admin.member-points.export', request()->query()) }}" class="button" style="display:inline-flex;align-items:center;">Export Excel</a>
    </div>

    <div class="card">
        <h2 class="card__title">Riwayat Poin Member</h2>

        <form method="GET" class="filters">
            <div class="field">
                <label for="search">Cari transaksi</label>
                <input id="search" type="text" name="search" value="{{ $filters['search'] ?? '' }}" placeholder="Invoice, member, user">
            </div>
            <div class="field">
                <label for="status">Status Sinkron</label>
                <select id="status" name="status">
                    <option value="">Semua</option>
                    <option value="verified" @selected(($filters['status'] ?? '') === 'verified')>Verified</option>
                    <option value="history_verified" @selected(($filters['status'] ?? '') === 'history_verified')>History Verified</option>
                    <option value="pending" @selected(($filters['status'] ?? '') === 'pending')>Pending</option>
                    <option value="failed" @selected(($filters['status'] ?? '') === 'failed')>Failed</option>
                </select>
            </div>
            <div class="field">
                <label for="date_from">Dari Tanggal</label>
                <input id="date_from" type="date" name="date_from" value="{{ $filters['date_from'] ?? '' }}">
            </div>
            <div class="field">
                <label for="date_to">Sampai Tanggal</label>
                <input id="date_to" type="date" name="date_to" value="{{ $filters['date_to'] ?? '' }}">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.member-points.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Invoice</th>
                        <th>User Kasir</th>
                        <th>Member</th>
                        <th>Poin</th>
                        <th>Nilai Rupiah</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($mutations as $mutation)
                        <tr>
                            <td>{{ $mutation->created_at?->format('d M Y H:i') }}</td>
                            <td><a href="{{ route('admin.invoices.show', $mutation) }}"><strong>{{ $mutation->invoice_number }}</strong></a></td>
                            <td>{{ $mutation->user?->name ?? $mutation->cashier_name_snapshot }}</td>
                            <td>
                                <div>{{ $mutation->member_name_snapshot ?: '-' }}</div>
                                <div class="list-item__meta">ID {{ $mutation->member_external_id ?: '-' }}</div>
                            </td>
                            <td>{{ number_format((int) $mutation->member_points_used) }} poin</td>
                            <td>Rp {{ number_format((float) $mutation->member_points_value_amount, 0, ',', '.') }}</td>
                            <td>
                                @php
                                    $status = (string) ($mutation->member_point_status ?: 'unknown');
                                    $badgeClass = match ($status) {
                                        'verified', 'history_verified' => 'badge--success',
                                        'failed' => 'badge--danger',
                                        default => 'badge--warning',
                                    };
                                @endphp
                                <span class="badge {{ $badgeClass }}">{{ $status }}</span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7"><div class="empty-state">Belum ada transaksi yang memakai poin member.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @include('admin.partials.pagination', ['paginator' => $mutations])
    </div>
@endsection
