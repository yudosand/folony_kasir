@extends('admin.layouts.app')

@section('title', 'Detail Pembukuan Stok')

@section('content')
    @php
        $product = $detail['product'];
        $summary = $detail['summary'];
        $status = $detail['status'];
        $movements = $detail['movements'];
        $badgeClass = match ($status['code'] ?? 'healthy') {
            'out' => 'badge badge--danger',
            'low' => 'badge badge--warning',
            default => 'badge badge--success',
        };
    @endphp

    <div class="admin-topbar">
        <div>
            <h1 class="admin-topbar__title">{{ $product->name }}</h1>
            <div class="admin-topbar__subtitle">
                Detail kartu stok untuk melihat asal stok awal, restock, penyesuaian, dan barang keluar karena transaksi.
            </div>
        </div>
        <a href="{{ route('admin.stock-bookkeeping.index') }}" class="button button--ghost" style="display:inline-flex;align-items:center;">Kembali ke Stock Bookkeeping</a>
    </div>

    <div class="card">
        <h2 class="card__title">Ringkasan Pembukuan</h2>
        <div class="detail-grid">
            <div class="detail-card">
                <div class="detail-card__label">Pemilik</div>
                <div class="detail-card__value">{{ $product->user?->name ?? '-' }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Status</div>
                <div class="detail-card__value"><span class="{{ $badgeClass }}">{{ $status['label'] ?? 'Aman' }}</span></div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Awal</div>
                <div class="detail-card__value">{{ number_format((int) $summary['initial_stock']) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Awal Periode</div>
                <div class="detail-card__value">{{ number_format((int) $summary['stock_at_period_start']) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Masuk</div>
                <div class="detail-card__value">{{ number_format((int) $summary['stock_in']) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Keluar</div>
                <div class="detail-card__value">{{ number_format((int) $summary['stock_out']) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Stok Saat Ini</div>
                <div class="detail-card__value">{{ number_format((int) $product->stock) }}</div>
            </div>
            <div class="detail-card">
                <div class="detail-card__label">Minimum Stok</div>
                <div class="detail-card__value">{{ number_format((int) $product->minimum_stock) }}</div>
            </div>
        </div>
    </div>

    <div class="card" style="margin-top: 18px;">
        <h2 class="card__title">Riwayat Mutasi Stok</h2>

        <form method="GET" class="filters filters--compact">
            <div class="field">
                <label for="date_from">Dari tanggal</label>
                <input id="date_from" type="date" name="date_from" value="{{ $filters['date_from'] ?? '' }}">
            </div>
            <div class="field">
                <label for="date_to">Sampai tanggal</label>
                <input id="date_to" type="date" name="date_to" value="{{ $filters['date_to'] ?? '' }}">
            </div>
            <div class="field" style="align-self:end;">
                <button type="submit" class="button">Terapkan Filter</button>
            </div>
            <div class="field" style="align-self:end;">
                <a href="{{ route('admin.stock-bookkeeping.show', $product) }}" class="button button--ghost" style="display:inline-flex;align-items:center;justify-content:center;">Reset</a>
            </div>
        </form>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Tanggal</th>
                        <th>Tipe</th>
                        <th>Arah</th>
                        <th>Qty</th>
                        <th>Sebelum</th>
                        <th>Sesudah</th>
                        <th>Referensi</th>
                        <th>Catatan</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($movements as $movement)
                        <tr>
                            <td>{{ $movement->created_at?->format('d M Y H:i') ?? '-' }}</td>
                            <td>{{ ucfirst($movement->type) }}</td>
                            <td>{{ $movement->direction === 'in' ? 'Masuk' : 'Keluar' }}</td>
                            <td>{{ number_format((int) $movement->quantity) }}</td>
                            <td>{{ number_format((int) $movement->stock_before) }}</td>
                            <td>{{ number_format((int) $movement->stock_after) }}</td>
                            <td>
                                @if ($movement->reference_type === 'transaction')
                                    Invoice #{{ $movement->reference_id }}
                                @else
                                    {{ ucfirst((string) $movement->reference_type) }}
                                @endif
                            </td>
                            <td>{{ $movement->notes ?: '-' }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8"><div class="empty-state">Belum ada mutasi stok pada filter periode ini.</div></td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
