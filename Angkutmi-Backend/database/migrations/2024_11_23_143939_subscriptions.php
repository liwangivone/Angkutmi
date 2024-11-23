<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->unsignedBigInteger('subscription_id')->primary();
            $table->integer('user_id');
            $table->string('duration');
            $table->string('purchase_date');
            $table->string('expired_date');
            $table->string('discount_rate');
            $table->timestamps();

            $table->foreign('user_id')
                  ->references('phone_number')
                  ->on('users')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription', function (Blueprint $table) {
            $table->dropForeign(['phone_number']);
        });

        Schema::dropIfExists('subscription');
    }
};
