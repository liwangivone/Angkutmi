<?php

namespace App\Http\Controllers;

use App\Models\Subscription;
use App\Models\TpaLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class SubscriptionController extends Controller
{
    public function createSubscription(Request $request)
    {
        // Validate the input, including time
        $validated = $request->validate([
            'package_name' => 'required|string',
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'schedule_date' => 'required|date',
            'schedule_time' => 'required|date_format:H:i', // Validate time in HH:MM format
        ]);

        // Define available packages and their prices
        $packages = [
            ['name' => 'Paket 1 Bulan', 'price' => 45000],
            ['name' => 'Paket 3 Bulan', 'price' => 80000],
            ['name' => 'Paket 6 Bulan', 'price' => 125000],
        ];

        // Find the selected package
        $package = collect($packages)->firstWhere('name', $validated['package_name']);

        if (!$package) {
            return response()->json(['error' => 'Invalid package selected'], 400);
        }

        // Find the nearest TPA
        $nearestTpa = TpaLocation::all()->sortBy(function ($tpa) use ($validated) {
            return $this->haversine(
                $validated['lat'],
                $validated['lng'],
                $tpa->latitude,
                $tpa->longitude
            );
        })->first();

        if (!$nearestTpa) {
            return response()->json(['error' => 'No TPA locations found.'], 400);
        }

        // Create the subscription
        $subscription = Subscription::create([
            'user_id' => Auth::id(),
            'package_name' => $validated['package_name'],
            'price' => $package['price'],
            'address' => json_encode(['lat' => $validated['lat'], 'lng' => $validated['lng']]),
            'schedule_date' => $validated['schedule_date'],
            'schedule_time' => $validated['schedule_time'], // Store the schedule time
            'tpa_id' => $nearestTpa->id, // Nearest TPA location
        ]);

        // Automatically schedule the daily trips for this subscription
        $subscription->scheduleSubscriptionTrips();
        // Log::info('Subscription created successfully', ['subscription' => $subscription]);
        return response()->json([
            'message' => 'Subscription created and daily trips scheduled successfully',
            'subscription' => $subscription->only(['id', 'package_name', 'price', 'schedule_date', 'schedule_time', 'tpa_id']),
        ]);
    }

    private function haversine($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
    {
        $radius = 6371; // Earth's radius in kilometers
        $latFrom = deg2rad($latitudeFrom);
        $lonFrom = deg2rad($longitudeFrom);
        $latTo = deg2rad($latitudeTo);
        $lonTo = deg2rad($longitudeTo);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $radius * $c;
    }
}
