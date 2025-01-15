<?php

// app/Models/Subscription.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'package_name', 'price', 'address', 'schedule_date','schedule_time'
    ];

    // Function to handle subscription duration and automatic daily trip scheduling
    public function scheduleSubscriptionTrips()
    {
        $startDate = Carbon::parse($this->schedule_date);

        // Define trip duration based on the package
        switch ($this->package_name) {
            case 'Paket 1 Bulan':
                $duration = 30; // 30 days
                break;
            case 'Paket 3 Bulan':
                $duration = 90; // 90 days
                break;
            case 'Paket 6 Bulan':
                $duration = 180; // 180 days
                break;
            default:
                return;
        }

        $this->createDailyTrips($startDate, $duration);
    }

    // Create daily trips for the subscription's duration
    private function createDailyTrips($startDate, $duration)
    {
        for ($i = 0; $i < $duration; $i++) {
            $scheduledDate = $startDate->copy()->addDays($i);

            // Here, you can trigger the scheduling logic (e.g., saving trip data, notifications, etc.)
            // For now, just outputting the scheduled dates for testing
            // echo "Scheduled trip for: " . $scheduledDate->toDateString() . "\n";
        }
    }
}
