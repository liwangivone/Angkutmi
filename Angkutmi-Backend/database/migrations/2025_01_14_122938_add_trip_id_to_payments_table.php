<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddTripIdToPaymentsTable extends Migration
{
    public function up()
    {
        Schema::table('payments', function (Blueprint $table) {
            // Add trip_id column to payments table
            $table->unsignedBigInteger('trip_id')->nullable()->after('id');
            
            // Add the foreign key constraint
            $table->foreign('trip_id')->references('id')->on('trips')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::table('payments', function (Blueprint $table) {
            // Remove the foreign key and the trip_id column
            $table->dropForeign(['trip_id']);
            $table->dropColumn('trip_id');
        });
    }
}
