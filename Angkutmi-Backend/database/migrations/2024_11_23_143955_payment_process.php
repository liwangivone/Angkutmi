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
        Schema::create('payment_processes', function (Blueprint $table) {
            $table->id(); // Primary key for the payment process record
            $table->unsignedBigInteger('trip_id'); // Foreign key for trips
            $table->unsignedBigInteger('payment_id'); // Foreign key for payments
            $table->integer('base_price');
            $table->integer('final_price');
            $table->boolean('payment_status')->default(false);
            $table->timestamps();

            // Define foreign key relationships
            $table->foreign('trip_id')
                  ->references('id') // References the `id` column in trips table
                  ->on('trips')
                  ->onDelete('cascade');

            $table->foreign('payment_id')
                  ->references('id') // References the `id` column in payments table
                  ->on('payments')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payment_processes', function (Blueprint $table) {
            $table->dropForeign(['trip_id']);
            $table->dropForeign(['payment_id']);
        });

        Schema::dropIfExists('payment_processes');
    }
};
