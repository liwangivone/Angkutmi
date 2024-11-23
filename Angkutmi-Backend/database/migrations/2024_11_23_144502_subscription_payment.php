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
        Schema::create('subscription_payment', function (Blueprint $table) {
            $table->unsignedBigInteger('subscription_id');
            $table->unsignedBigInteger('payment_id');
            $table->string('subscription_price');
            $table->string('payment_status');
            $table->timestamps();

            $table->foreign('subscription_id')
                  ->references('subscription_id')
                  ->on('subscriptions')
                  ->onDelete('cascade');

            $table->foreign('payment_id')
                  ->references('payment_id')
                  ->on('payments')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {   
        Schema::table('subscription_payment', function (Blueprint $table) {
        $table->dropForeign(['subscription_id']);
         });

        Schema::table('subscription_payment', function (Blueprint $table) {
            $table->dropForeign(['payment_id']);
        });

        Schema::dropIfExists('subscription_payment');
    }
};
