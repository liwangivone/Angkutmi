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
            $table->unsignedBigInteger('vehicle_id'); // Foreign key for vehicles
            $table->unsignedBigInteger('user_id'); // Foreign key for users (added field)
            $table->timestamps(); // Timestamps for created_at and updated_at

            // Foreign key relationship with vehicles table
            $table->foreign('vehicle_id')
                  ->references('vehicle_id')
                  ->on('vehicles')
                  ->onDelete('cascade');

            // Foreign key relationship with users table
            $table->foreign('user_id')
                  ->references('id') // Assuming `id` is the primary key in `users` table
                  ->on('users')
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
            $table->dropForeign(['user_id']); // Drop foreign key for user_id
        });

        Schema::dropIfExists('drivers');
    }
};
