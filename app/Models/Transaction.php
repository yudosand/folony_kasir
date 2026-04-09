<?php

namespace App\Models;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Transaction extends Model
{
    protected $fillable = [
        'user_id',
        'invoice_number',
        'store_name_snapshot',
        'store_address_snapshot',
        'store_phone_snapshot',
        'store_logo_path_snapshot',
        'invoice_footer_snapshot',
        'cashier_name_snapshot',
        'cashier_email_snapshot',
        'member_external_id',
        'member_name_snapshot',
        'member_points_before',
        'member_points_used',
        'member_points_after',
        'member_points_value_amount',
        'member_point_status',
        'member_point_description',
        'member_point_mutation_payload',
        'item_count',
        'subtotal',
        'grand_total',
        'payment_method',
        'payment_status',
        'cash_amount',
        'non_cash_amount',
        'amount_paid',
        'change_amount',
        'due_amount',
    ];

    protected function casts(): array
    {
        return [
            'item_count' => 'integer',
            'member_external_id' => 'integer',
            'member_points_before' => 'integer',
            'member_points_used' => 'integer',
            'member_points_after' => 'integer',
            'member_points_value_amount' => 'decimal:2',
            'member_point_mutation_payload' => 'array',
            'subtotal' => 'decimal:2',
            'grand_total' => 'decimal:2',
            'cash_amount' => 'decimal:2',
            'non_cash_amount' => 'decimal:2',
            'amount_paid' => 'decimal:2',
            'change_amount' => 'decimal:2',
            'due_amount' => 'decimal:2',
            'payment_method' => PaymentMethod::class,
            'payment_status' => PaymentStatus::class,
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(TransactionItem::class);
    }

    public function scopeOwnedBy(Builder $query, User|int $user): Builder
    {
        $userId = $user instanceof User ? $user->id : $user;

        return $query->where('user_id', $userId);
    }
}
