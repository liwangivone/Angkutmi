<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\TpaLocation;
use App\Models\Trip;
use App\Events\TripStarted;
use App\Events\TripAccepted;
use App\Events\TripEnded;
use App\Events\TripCreated;
use App\Events\TripLocationUpdated;


class TripController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/trips",
     *     summary="Create a new trip",
     *     description="Endpoint to create a new trip",
     *     tags={"Trips"},
     *     security={{"sanctum": {}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"origin", "destination", "destination_name"},
     *             @OA\Property(property="origin", type="object", description="Origin coordinates (array with lat and lng)", example={"lat": -5.135399, "lng": 119.412293}),
     *             @OA\Property(property="destination", type="object", description="Destination coordinates (array with lat and lng)", example={"lat": -5.135831, "lng": 119.422559}),
     *             @OA\Property(property="destination_name", type="string", description="Name of the destination", example="Mall Panakkukang")
     *         )
     *     ),
     *     @OA\Response(response=201, description="Trip created successfully"),
     *     @OA\Response(response=400, description="Validation error"),
     *     @OA\Response(response=500, description="Internal server error")
     * )
     */
    public function store(Request $request)
    {
        $request->validate([
            'origin' => 'required|array',
            'vehicle_type' => 'required|string|in:motor,pickup,truck',
        ]);
    
        $user = $request->user();
        $origin = $request->origin;
    
        // Find the nearest TPA
        $nearestTpa = TpaLocation::all()->sortBy(function ($tpa) use ($origin) {
            return $this->haversine(
                $origin['lat'],
                $origin['lng'],
                $tpa->latitude,
                $tpa->longitude
            );
        })->first();
    
        if (!$nearestTpa) {
            return response()->json(['message' => 'No TPA locations found.'], 400);
        }
    
        // Calculate the distance to the nearest TPA
        $distanceToTpa = $this->haversine(
            $origin['lat'],
            $origin['lng'],
            $nearestTpa->latitude,
            $nearestTpa->longitude
        );
    
        // Calculate the price
        $price = $this->calculateTripPrice($distanceToTpa, $request->vehicle_type);
    
        // Create the trip
        $trip = $user->trips()->create([
            'origin' => $origin,
            'destination' => [
                'lat' => $nearestTpa->latitude,
                'lng' => $nearestTpa->longitude,
            ],
            'destination_name' => $nearestTpa->name,
            'vehicle_type' => $request->vehicle_type,
            'price' => $price, // Save the price in the trip
        ]);
    
        TripCreated::dispatch($trip, $user);
    
        return response()->json([
            'message' => 'Trip created successfully.',
            'trip' => $trip->fresh(), // Include updated trip data
            'price' => $price,
        ], 201);
    }
        /**
     * @OA\Post(
     *     path="/api/trips/{trip}/accept",
     *     summary="Accept a trip",
     *     description="Endpoint for drivers to accept a trip",
     *     tags={"Trips"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="trip",
     *         in="path",
     *         required=true,
     *         description="ID of the trip",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"driver_location"},
     *             @OA\Property(property="driver_location", type="object", description="Driver's current location (array with lat and lng)", example={"lat": -5.135999, "lng": 119.411111})
     *         )
     *     ),
     *     @OA\Response(response=200, description="Trip accepted successfully"),
     *     @OA\Response(response=400, description="Trip already accepted or validation error"),
     *     @OA\Response(response=500, description="Internal server error")
     * )
     */
    public function accept(Request $request, Trip $trip)
    {
        $driver = $request->user()->driver;
    
        // Ensure the driver has a vehicle
        if (!$driver || !$driver->vehicle) {
            return response()->json(['message' => 'Driver does not have an assigned vehicle.'], 403);
        }
    
        // Check if the trip matches the driver's vehicle type
        if ($trip->vehicle_type !== $driver->vehicle->type) {
            return response()->json(['message' => 'You cannot accept this trip. Vehicle type mismatch.'], 403);
        }
    
        $request->validate([
            'driver_location' => 'required'
        ]);
    
        if ($trip->driver_id) {
            return response()->json(['message' => 'This trip has already been accepted by another driver.'], 400);
        }
    
        try {
            $trip->update([
                'driver_id' => $request->user()->id,
                'driver_location' => $request->driver_location,
            ]);
    
            $trip->load('driver.user');
    
            TripAccepted::dispatch($trip, $trip->user);
    
            return $trip;
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to accept the trip. Please try again.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
    
    /**
     * @OA\Post(
     *     path="/api/trips/{trip}/start",
     *     summary="Start a trip",
     *     description="Endpoint to start a trip",
     *     tags={"Trips"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="trip",
     *         in="path",
     *         required=true,
     *         description="ID of the trip",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(response=200, description="Trip started successfully"),
     *     @OA\Response(response=400, description="Trip has already started"),
     *     @OA\Response(response=500, description="Internal server error")
     * )
     */
    public function start(Request $request, Trip $trip)
    {
        $driver = $request->user()->driver;
    
        // Ensure the driver has a vehicle
        if (!$driver || !$driver->vehicle) {
            return response()->json(['message' => 'Driver does not have an assigned vehicle.'], 403);
        }
    
        // Check if the trip matches the driver's vehicle type
        if ($trip->vehicle_type !== $driver->vehicle->type) {
            return response()->json(['message' => 'You cannot start this trip. Vehicle type mismatch.'], 403);
        }
    
        if ($trip->is_started) {
            return response()->json(['message' => 'This trip has already started.'], 400);
        }
    
        $trip->update([
            'is_started' => true,
        ]);
    
        $trip->load('driver.user');
    
        TripStarted::dispatch($trip, $request->user());
    
        return response()->json($trip, 200);
    }
    
    /**
     * @OA\Post(
     *     path="/api/trips/{trip}/end",
     *     summary="End a trip",
     *     description="Endpoint to end a trip",
     *     tags={"Trips"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="trip",
     *         in="path",
     *         required=true,
     *         description="ID of the trip",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(response=200, description="Trip ended successfully"),
     *     @OA\Response(response=400, description="Validation error or invalid distance"),
     *     @OA\Response(response=500, description="Internal server error")
     * )
     */
    /**
     * End a trip and calculate the price.
     */
    public function end(Request $request, Trip $trip)
    {
        $driver = $request->user()->driver;
    
        if (!$driver) {
            return response()->json(['message' => 'Driver not found.'], 403);
        }
    
        if ($trip->is_completed) {
            return response()->json(['message' => 'Trip is already completed.'], 400);
        }
    
        $origin = $trip->origin;
        $destination = $trip->destination;
        $driverLocation = $trip->driver_location;
    
        if (!$origin || !$destination || !$driverLocation) {
            return response()->json(['message' => 'Required location data is missing.'], 400);
        }
    
        $originLat = $origin['lat'];
        $originLng = $origin['lng'];
        $destinationLat = $destination['lat'];
        $destinationLng = $destination['lng'];
        $driverLat = $driverLocation['lat'];
        $driverLng = $driverLocation['lng'];
    
        // Calculate distances
        $distanceToTpa = $this->haversine($originLat, $originLng, $destinationLat, $destinationLng);
        $distanceToOriginFromDriver = $this->haversine($driverLat, $driverLng, $originLat, $originLng);
    
        // Calculate price
        $price = $this->calculateTripPrice($distanceToTpa, $distanceToOriginFromDriver);
    
        // Update trip as completed and set the price
        $trip->update([
            'is_completed' => true,
            'price' => $price,
        ]);
    
        // Increment the trip count for the user who created the trip
        $tripCreator = $trip->user; // Assuming a `user` relationship exists on the Trip model
        $tripCount = $tripCreator->trip_count ?? 0; // Default to 0 if not set
        $tripCreator->update(['trip_count' => $tripCount + 1]);
    
        TripEnded::dispatch($trip, $tripCreator);
    
        return response()->json([
            'message' => 'Trip has ended successfully.',
            'trip' => $trip,
            'price' => $price,
            'trip_count' => $tripCreator->trip_count,
        ]);
    }
    
          /**
     * @OA\Post(
     *     path="/api/trips/{trip}/location",
     *     summary="Update driver location",
     *     description="Endpoint to update the driver's current location",
     *     tags={"Trips"},
     *     security={{"sanctum": {}}},
     *     @OA\Parameter(
     *         name="trip",
     *         in="path",
     *         required=true,
     *         description="ID of the trip",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"driver_location"},
     *             @OA\Property(property="driver_location", type="object", description="Driver's current location (array with lat and lng)", example={"lat": -5.135999, "lng": 119.411111})
     *         )
     *     ),
     *     @OA\Response(response=200, description="Driver location updated successfully"),
     *     @OA\Response(response=400, description="Validation error"),
     *     @OA\Response(response=500, description="Internal server error")
     * )
     */
    public function location(Request $request, Trip $trip)
    {
        $request->validate([
            'driver_location' => 'required'
        ]);

        $trip->update([
            'driver_location' => $request->driver_location,
        ]);

        $trip->load('driver.user');

        TripLocationUpdated::dispatch($trip, $request->user());

        return $trip;
    }

    /**
     * Calculate the distance between two coordinates using the haversine formula.
     */
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

    /**
     * Calculate the trip price based on distances.
     */
/**
 * Calculate the trip price based on distances.
 */
public function calculateTripPrice($distance, $landfillType)
{
    $baseFee = 5000; // Fixed base fee in Rupiah (adjusted to Rupiah)
    $perKmRate = 1000; // Rate per kilometer in Rupiah
    // Remove landfill surcharge by not adding it to the total price

    // Calculate price
    $distanceCharge = $distance * $perKmRate;
    $totalPrice = $baseFee + $distanceCharge;

    return $totalPrice;
}


    /**
 * @OA\Get(
 *     path="/api/trips/{trip}",
 *     summary="Get a specific trip",
 *     description="Retrieve details of a specific trip by ID",
 *     tags={"Trips"},
 *     security={{"sanctum": {}}},
 *     @OA\Parameter(
 *         name="trip",
 *         in="path",
 *         required=true,
 *         description="ID of the trip",
 *         @OA\Schema(type="integer")
 *     ),
 *     @OA\Response(response=200, description="Trip details retrieved successfully"),
 *     @OA\Response(response=404, description="Trip not found"),
 *     @OA\Response(response=500, description="Internal server error")
 * )
 */

    public function show(Trip $trip)
{
    return response()->json([
        'success' => true,
        'trip_id' => $trip->id,
        'price' => $trip->price,
    ]);
    
}

}
