<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\TpaLocation;

class TpaLocationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        TpaLocation::insert([
            [
                'name' => 'TPA Sampah Antang 1',
                'latitude' => -5.158216745561893,
                'longitude' => 119.49168119293496,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'TPA Sampah Antang 2',
                'latitude' => -5.176488033537476,
                'longitude' => 119.4909957659506,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'TPS Rappokalling',
                'latitude' => -5.123386903174294,
                'longitude' => 119.43928778416988,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'TPA Bontoramba',
                'latitude' => -5.067811334734829,
                'longitude' => 119.58015620341382,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'UPTD TPA Tamangapa Raya',
                'latitude' => -5.1738661790787175,
                'longitude' => 119.48938299129021,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'TPA Sampah Maros',
                'latitude' => -5.067526243974985,
                'longitude' => 119.57912208421654,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
