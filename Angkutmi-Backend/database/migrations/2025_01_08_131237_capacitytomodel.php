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
        Schema::table('vehicles', function (Blueprint $table) {
            // Change 'capacity' column to 'model' with string type
            $table->string('model')->after('type'); // Add new 'model' column
            $table->dropColumn('capacity'); // Remove 'capacity' column
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->integer('capacity')->after('type'); // Re-add 'capacity' column
            $table->dropColumn('model'); // Remove 'model' column
        });
    }
};
