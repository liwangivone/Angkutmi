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
        Schema::table('subscriptions', function (Blueprint $table) {
            // Add the package_name column if it doesn't already exist
            $table->string('package_name')->after('user_id')->nullable();

            // If you need to rename or change any other columns, do so here
            // For example, you could rename 'duration' to 'package_name' if that was the original intention
            // $table->renameColumn('duration', 'package_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            // Drop the added column if you want to roll back
            $table->dropColumn('package_name');
        });
    }
};
