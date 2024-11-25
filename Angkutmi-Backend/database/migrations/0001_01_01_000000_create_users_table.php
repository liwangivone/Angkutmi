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
        Schema::create('users', function (Blueprint $table) {
            $table->id();  // Primary key
            $table->string('phone_number')->unique();
            $table->string('name');
            $table->timestamp('phone_number_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
        

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('reset_id')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            // The session ID is used as the primary key for the session table.
            $table->string('id')->primary(); // `id` should be the primary key for session identification.
        
            // Foreign key to associate the session with a user (nullable).
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade'); // This will create a foreign key on the `user_id` column.
        
            // Store the user's IP address and user agent (optional but useful for security).
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
        
            // Session payload storage (to hold session data).
            $table->longText('payload'); 
        
            // Store the last activity timestamp for the session.
            $table->integer('last_activity')->index(); // The index on this column allows efficient searching by last activity.
        
            // Timestamps can be useful for tracking when the session was created or updated.
            $table->timestamps();
        });
        
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
