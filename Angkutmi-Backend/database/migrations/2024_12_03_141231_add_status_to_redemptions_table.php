<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('redemptions', function (Blueprint $table) {
            $table->enum('status', ['claimed', 'redeemed'])->default('claimed');
        });
    }
    
    public function down()
    {
        Schema::table('redemptions', function (Blueprint $table) {
            $table->dropColumn('status');
        });
    }
    
};
