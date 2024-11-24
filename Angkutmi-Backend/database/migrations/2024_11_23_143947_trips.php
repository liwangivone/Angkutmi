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
        Schema::create('trips', function (Blueprint $table) {
            $table->id('trip_id'); // Primary key
            $table->unsignedBigInteger('user_id'); // Foreign key to `users(id)`
            $table->unsignedBigInteger('driver_id'); // Foreign key to `drivers(id)`
            $table->unsignedBigInteger('subscription_id'); // Foreign key to `subscriptions(subscription_id)`
            $table->boolean('is_started')->default(false);
            $table->boolean('is_completed')->default(false);
            $table->json('origin');
            $table->json('destination');
            $table->json('driver_location');
            $table->dateTime('reserve_datetime');
            $table->timestamps();

            // Define foreign key relationships
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');
            
            $table->foreign('driver_id')
                  ->references('id')
                  ->on('drivers')
                  ->onDelete('cascade');

            $table->foreign('subscription_id')
                  ->references('subscription_id')
                  ->on('subscriptions')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['driver_id']);
            $table->dropForeign(['subscription_id']);
        });

        Schema::dropIfExists('trips');
    }
};