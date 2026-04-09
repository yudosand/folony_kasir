<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->unsignedBigInteger('member_external_id')->nullable()->after('cashier_email_snapshot');
            $table->string('member_name_snapshot')->nullable()->after('member_external_id');
            $table->unsignedBigInteger('member_points_before')->nullable()->after('member_name_snapshot');
            $table->unsignedBigInteger('member_points_used')->default(0)->after('member_points_before');
            $table->unsignedBigInteger('member_points_after')->nullable()->after('member_points_used');
            $table->decimal('member_points_value_amount', 15, 2)->default(0)->after('member_points_after');
            $table->string('member_point_status', 20)->default('none')->after('member_points_value_amount');
            $table->text('member_point_description')->nullable()->after('member_point_status');
            $table->json('member_point_mutation_payload')->nullable()->after('member_point_description');

            $table->index(['user_id', 'member_external_id']);
            $table->index(['user_id', 'member_point_status']);
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropIndex(['user_id', 'member_external_id']);
            $table->dropIndex(['user_id', 'member_point_status']);
            $table->dropColumn([
                'member_external_id',
                'member_name_snapshot',
                'member_points_before',
                'member_points_used',
                'member_points_after',
                'member_points_value_amount',
                'member_point_status',
                'member_point_description',
                'member_point_mutation_payload',
            ]);
        });
    }
};
