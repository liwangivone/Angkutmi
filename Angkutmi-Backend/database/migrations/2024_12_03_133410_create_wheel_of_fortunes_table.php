<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateWheelOfFortunesTable extends Migration
{
    public function up(): void
    {
        Schema::create('wheel_of_fortunes', function (Blueprint $table) {
            $table->id();
            $table->string('label'); // Label for the slice (e.g., "10% Progress")
            $table->integer('percentage'); // Percentage progress it adds
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wheel_of_fortunes');
    }
}
