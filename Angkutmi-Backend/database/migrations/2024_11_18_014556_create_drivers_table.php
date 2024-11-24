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
        Schema::create('drivers', function (Blueprint $table) {
            $table->id(); // Primary key `id` for drivers table (auto-incrementing)
            $table->string('phone_number')->unique(); // Unique phone number for driver
            $table->unsignedBigInteger('vehicle_id'); // Foreign key for vehicles
            $table->string('password'); // Driver's password
            $table->timestamps(); // Timestamps for created_at and updated_at

            // Foreign key relationship with vehicles table
            $table->foreign('vehicle_id')
                  ->references('vehicle_id')
                  ->on('vehicles')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('drivers', function (Blueprint $table) {
            $table->dropForeign(['vehicle_id']);
        });

        Schema::dropIfExists('drivers');
    }
};
