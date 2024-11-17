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
            $table->integer('phone_number')->primary();
            $table->unsignedBigInteger('vehicle_id');
            $table->string('password');
            $table->timestamps();

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
