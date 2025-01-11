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
        // Create subscriptions table
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id(); // Primary key
            $table->string('package_name'); // Subscription package name
            $table->decimal('price', 10, 2)->nullable(); // Price column
            $table->json('address')->nullable(); // Address column for lat/lng
            $table->date('schedule_date')->nullable(); // Schedule date
            $table->unsignedBigInteger('tpa_id')->nullable(); // Foreign key for TPA location
            $table->timestamps(); // Created at and updated at timestamps

            // Define foreign key constraint for tpa_id
            $table->foreign('tpa_id')->references('id')->on('tpa_locations')->onDelete('cascade');
        });

        // Create payments table
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

        // Drop subscriptions table and its constraints
        Schema::dropIfExists('subscriptions');
    }
};
