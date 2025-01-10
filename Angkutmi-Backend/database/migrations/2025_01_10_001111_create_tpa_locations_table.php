<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTpaLocationsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tpa_locations', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Name of the landfill
            $table->decimal('latitude', 10, 7); // Latitude of the landfill
            $table->decimal('longitude', 10, 7); // Longitude of the landfill
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tpa_locations');
    }
}
