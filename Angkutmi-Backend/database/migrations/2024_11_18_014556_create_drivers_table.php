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
            $table->id(); // Primary key `driver_id`
            $table->unsignedBigInteger('user_id'); // Foreign key to `users` table, now non-nullable
            $table->unsignedBigInteger('vehicle_id'); // Foreign key to `vehicles` table
            $table->string('profile_picture')->nullable(); // Path or filename for profile picture
            $table->timestamps(); // Laravel's created_at and updated_at timestamps

            // Define foreign keys
            $table->foreign('user_id')
                  ->references('id') // Assuming `id` is the primary key in `users`
                  ->on('users')
                  ->onDelete('cascade');

            $table->foreign('vehicle_id')
                  ->references('id') // Assuming `vehicle_id` is the primary key in `vehicles`
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
            $table->dropForeign(['user_id']); // Drop foreign key for `user_id`
            $table->dropForeign(['vehicle_id']); // Drop foreign key for `vehicle_id`
        });

        Schema::dropIfExists('drivers'); // Drop the table
    }
};
