@if ($paginator->hasPages())
    <div class="admin-pagination">
        <div class="admin-pagination__meta">
            Menampilkan {{ $paginator->firstItem() ?? 0 }}-{{ $paginator->lastItem() ?? 0 }} dari {{ $paginator->total() }} data
        </div>
        <div class="admin-pagination__actions">
            @if ($paginator->onFirstPage())
                <span class="admin-pagination__button is-disabled">Sebelumnya</span>
            @else
                <a class="admin-pagination__button" href="{{ $paginator->previousPageUrl() }}">Sebelumnya</a>
            @endif

            <span class="admin-pagination__current">
                Halaman {{ $paginator->currentPage() }} / {{ $paginator->lastPage() }}
            </span>

            @if ($paginator->hasMorePages())
                <a class="admin-pagination__button" href="{{ $paginator->nextPageUrl() }}">Berikutnya</a>
            @else
                <span class="admin-pagination__button is-disabled">Berikutnya</span>
            @endif
        </div>
    </div>
@endif
