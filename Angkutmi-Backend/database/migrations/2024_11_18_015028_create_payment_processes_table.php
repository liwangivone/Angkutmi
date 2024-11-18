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
            $table->unsignedBigInteger('trip_id');
            $table->unsignedBigInteger('payment_id');
            $table->boolean('payment_status')->default(false);
            $table->timestamps();

            $table->foreign('trip_id')
                  ->references('trip_id')
                  ->on('trips')
                  ->onDelete('cascade');
      
            $table->foreign('payment_id')
                  ->references('payment_id')
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
        });

        Schema::table('payment_processes', function (Blueprint $table) {
            $table->dropForeign(['payment_id']);
        });

        Schema::dropIfExists('payment_processes');
    }
};
