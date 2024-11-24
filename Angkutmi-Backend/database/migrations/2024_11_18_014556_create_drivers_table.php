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
            $table->unsignedBigInteger('driver_id')->primary(); // Primary key `driver_id`
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('vehicle_id');
            $table->string('profile_picture')->nullable(); // Profile picture path or filename
            $table->timestamps(); // Timestamps for created_at and updated_at
    
            $table->foreign('user_id')
                  ->references('id') // References `id` in the `users` table
                  ->on('users')
                  ->onDelete('cascade');
    
            $table->foreign('vehicle_id')
                  ->references('vehicle_id') // Assuming `id` is the primary key in `vehicles` table
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
            $table->dropForeign(['user_id']);
            $table->dropForeign(['vehicle_id']);
        });

        Schema::dropIfExists('drivers');
    }
};
