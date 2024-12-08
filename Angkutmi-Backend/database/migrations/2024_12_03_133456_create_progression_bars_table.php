<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProgressionBarsTable extends Migration
{
    public function up(): void
    {
        Schema::create('progression_bars', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // Link to user
            $table->integer('progress')->default(0); // Current progress
            $table->boolean('reward_claimed')->default(false); // Has the reward been claimed?
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('progression_bars');
    }
}
