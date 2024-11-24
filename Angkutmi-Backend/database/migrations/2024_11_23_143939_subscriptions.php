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
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id('subscription_id'); // Primary key
            $table->unsignedBigInteger('user_id'); // Foreign key
            $table->string('duration');
            $table->date('purchase_date'); // Use `date` for dates
            $table->date('expired_date');  // Use `date` for dates
            $table->decimal('discount_rate', 5, 2); // Use `decimal` for rates (e.g., percentages)
            $table->timestamps();
        
            // Define the foreign key relationship
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');
        });
        
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription', function (Blueprint $table) {
            $table->dropForeign(['phone_number']);
        });

        Schema::dropIfExists('subscription');
    }
};
