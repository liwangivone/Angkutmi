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
            'destination' => 'required|array',
            'destination_name' => 'required|string',
            'vehicle_type' => 'required|string|in:motor,pickup,truck', // Validate vehicle type
        ]);
    
        $trip = $request->user()->trips()->create([
            'origin' => $request->origin,
            'destination' => $request->destination,
            'destination_name' => $request->destination_name,
            'vehicle_type' => $request->vehicle_type, // Store vehicle type
        ]);
    
        TripCreated::dispatch($trip, $request->user());
    
        return response()->json($trip, 201);
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
    public function end(Request $request, Trip $trip)
    {
        if ($trip->is_completed) {
            return response()->json(['message' => 'Trip is already completed.'], 400);
        }

        $origin = $trip->origin;
        $destination = $trip->destination;

        if (!$origin || !$destination) {
            return response()->json(['message' => 'Origin or destination coordinates are missing'], 400);
        }

        $originLat = $origin['lat'];
        $originLng = $origin['lng'];
        $destinationLat = $destination['lat'];
        $destinationLng = $destination['lng'];

        $distance = $this->haversine($originLat, $originLng, $destinationLat, $destinationLng);

        if ($distance <= 0) {
            return response()->json(['message' => 'Invalid distance calculated.'], 400);
        }

        $price = $this->calculateTripPrice($originLat, $originLng, $destinationLat, $destinationLng);

        $trip->update([
            'is_completed' => true,
            'price' => $price
        ]);

        $trip->load('driver.user');

        TripEnded::dispatch($trip, $request->user());

        return response()->json([
            'message' => 'Trip has ended successfully.',
            'trip' => $trip
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

    private function haversine($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo)
    {
        $radius = 6371;
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

    private function calculateTripPrice($originLat, $originLng, $destinationLat, $destinationLng)
    {
        $distance = $this->haversine($originLat, $originLng, $destinationLat, $destinationLng);

        $basePrice = 10;
        $pricePerKm = 2;

        return $basePrice + ($distance * $pricePerKm);
    }
}
