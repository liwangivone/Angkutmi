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
            $table->id(); // Primary key for the subscription_payment record
            $table->unsignedBigInteger('subscription_id'); // Foreign key for subscriptions
            $table->unsignedBigInteger('payment_id'); // Foreign key for payments
            $table->decimal('subscription_price', 8, 2); // Use decimal for price
            $table->string('payment_status'); // Payment status (e.g., 'pending', 'completed')
            $table->timestamps();

            // Define foreign key relationships
            $table->foreign('subscription_id')
                  ->references('subscription_id') // References the `subscription_id` column in subscriptions table
                  ->on('subscriptions')
                  ->onDelete('cascade');

            $table->foreign('payment_id')
                  ->references('payment_id') // References the `id` column in payments table
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
            $table->dropForeign(['payment_id']);
        });

        Schema::dropIfExists('subscription_payment');
    }
};
