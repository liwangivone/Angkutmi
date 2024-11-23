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
            $table->unsignedBigInteger('trip_id')->primary();
            $table->integer('user_phone_number');
            $table->integer('driver_phone_number');
            $table->unsignedBigInteger('subscription_id');
            $table->boolean('is_started')->default(false);
            $table->boolean('is_completed')->default(false);
            $table->json('origin');
            $table->json('destination');
            $table->json('driver_location');
            $table->dateTime('reserve_datetime');
            $table->timestamps();

            $table->foreign('user_phone_number')
                  ->references('phone_number')
                  ->on('users')
                  ->onDelete('cascade');
            
            $table->foreign('driver_phone_number')
                  ->references('phone_number')
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
            $table->dropForeign(['driver_id']);
        });

        Schema::table('trips', function (Blueprint $table) {
            $table->dropForeign(['phone_number']);
        });

        Schema::table('trips', function (Blueprint $table) {
            $table->dropForeign(['subscription_id']);
        });

        Schema::dropIfExists('trips');
    }
};