<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Trip;
use App\Events\TripStarted;
use App\Events\TripAccepted;
use App\Events\TripEnded;
use App\Events\TripCreated;
use App\Events\TripLocationUpdated;


class TripController extends Controller
{


    public function store(Request $request)
    {
        // Validate the incoming request data
        $request->validate([
            'origin' => 'required|array',  // Ensure 'origin' is an array
            'destination' => 'required|array',  // Ensure 'destination' is an array
            'destination_name' => 'required|string',  // Ensure 'destination_name' is a string
        ]);
    
        // Create the trip and save to the database
        $trip = $request->user()->trips()->create([
            'origin' => $request->origin,  // Pass the 'origin' directly as it is
            'destination' => $request->destination,  // Pass the 'destination' directly as it is
            'destination_name' => $request->destination_name,  // Pass the destination name
        ]);
    
        // Dispatch the TripCreated event
        TripCreated::dispatch($trip, $request->user());
    
        // Return the created trip
        return response()->json($trip, 201);
    }
    
    public function accept(Request $request, Trip $trip)
    {
        // Validate the required driver location field
        $request->validate([
            'driver_location' => 'required'
        ]);
    
        // Check if the trip already has an assigned driver
        if ($trip->driver_id) {
            return response()->json(['message' => 'This trip has already been accepted by another driver.'], 400);
        }
    
        try {
            // If the trip does not have a driver, assign the driver and update the trip
            $trip->update([
                'driver_id' => $request->user()->id, // Assign the driver who is accepting the trip
                'driver_location' => $request->driver_location, // Update the driver's location
            ]);
    
            // Load the driver and user relationships for further use
            $trip->load('driver.user');
    
            // Dispatch the event that the trip has been accepted
            TripAccepted::dispatch($trip, $trip->user);
    
            return $trip;
    
        } catch (\Exception $e) {
            // Handle exceptions during the trip update process
            return response()->json([
                'message' => 'Failed to accept the trip. Please try again.',
                'error' => $e->getMessage(), // Include error message for debugging (optional)
            ], 500);
        }
    }
    public function start(Request $request, Trip $trip)
{
    // Check if the trip has already started
    if ($trip->is_started) {
        return response()->json(['message' => 'This trip has already started.'], 400);
    }

    // Update the trip to mark it as started
    $trip->update([
        'is_started' => true,
    ]);

    // Load the driver and user relationships for further use
    $trip->load('driver.user');

    // Dispatch the TripStarted event with the trip and user
    TripStarted::dispatch($trip, $request->user());

    // Return the updated trip
    return response()->json($trip, 200);
}

    
    public function end(Request $request, Trip $trip)
    {
        // Check if the trip is already completed
        if ($trip->is_completed) {
            return response()->json(['message' => 'Trip is already completed.'], 400);
        }
    
        // Ensure both origin and destination are available
        $origin = $trip->origin;
        $destination = $trip->destination;
    
        if (!$origin || !$destination) {
            return response()->json(['message' => 'Origin or destination coordinates are missing'], 400);
        }
    
        // Extract latitude and longitude from origin and destination
        $originLat = $origin['lat'];
        $originLng = $origin['lng'];
        $destinationLat = $destination['lat'];
        $destinationLng = $destination['lng'];
    
        // Calculate the distance between origin and destination using the Haversine formula
        $distance = $this->haversine($originLat, $originLng, $destinationLat, $destinationLng);
    
        // Check if the distance is valid
        if ($distance <= 0) {
            return response()->json(['message' => 'Invalid distance calculated.'], 400);
        }
    
        // Calculate the price for the trip based on the distance
        $price = $this->calculateTripPrice($originLat, $originLng, $destinationLat, $destinationLng);
    
        // Update the trip status and set the price
        $trip->update([
            'is_completed' => true,
            'price' => $price
        ]);
    
        // Reload the trip with related driver data (optional)
        $trip->load('driver.user');
    
        // Dispatch the TripEnded event
        TripEnded::dispatch($trip, $request->user());
    
        // Return a success response with trip details
        return response()->json([
            'message' => 'Trip has ended successfully.',
            'trip' => $trip
        ]);
    }
    
    public function location(Request $request, Trip $trip)
    {
        // Validate the driver location field
        $request->validate([
            'driver_location' => 'required'
        ]);
    
        // Update the driver's location in the trip
        $trip->update([
            'driver_location' => $request->driver_location,
        ]);
    
        // Load the driver and user relationships
        $trip->load('driver.user');
    
        // Dispatch the TripLocationUpdated event
        TripLocationUpdated::dispatch($trip, $request->user());
    
        // Return the updated trip
        return $trip;
    }
    
    public function haversine($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
    {
        $radius = 6371; // Earth radius in kilometers
    
        // Convert degrees to radians
        $latFrom = deg2rad($latitudeFrom);
        $lonFrom = deg2rad($longitudeFrom);
        $latTo = deg2rad($latitudeTo);
        $lonTo = deg2rad($longitudeTo);
    
        // Haversine formula
        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;
    
        $a = sin($latDelta / 2) * sin($latDelta / 2) +
            cos($latFrom) * cos($latTo) *
            sin($lonDelta / 2) * sin($lonDelta / 2);
    
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
    
        // Distance in kilometers
        return $radius * $c;
    }
    
    public function calculateTripPrice($originLat, $originLng, $destinationLat, $destinationLng)
    {
        // Calculate the distance using the Haversine formula
        $distance = $this->haversine($originLat, $originLng, $destinationLat, $destinationLng);
    
        // Assuming a base rate and per kilometer price
        $basePrice = 10; // Example base price in your currency (e.g., $10)
        $pricePerKm = 2; // Example price per kilometer (e.g., $2 per km)
    
        // Calculate the total price (base price + price based on distance)
        $totalPrice = $basePrice + ($distance * $pricePerKm);
    
        return $totalPrice;
    }
}    