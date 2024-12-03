<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\WheelOfFortune;

class WheelOfFortuneSeeder extends Seeder
{
    public function run(): void
    {
        WheelOfFortune::insert([
            ['label' => '5% Progress', 'percentage' => 5],
            ['label' => '10% Progress', 'percentage' => 10],
            ['label' => '15% Progress', 'percentage' => 15],
            ['label' => '20% Progress', 'percentage' => 20],
        ]);
    }
}
