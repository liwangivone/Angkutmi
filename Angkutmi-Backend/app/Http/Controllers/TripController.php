<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Trip;
use App\Events\TripStarted;
use App\Events\TripAccepted;
use App\Events\TripEnded;
use App\Events\TripLocationUpdated;


class TripController extends Controller
{
    public function store(Request $request){
        $request->validate([
            'origin' => 'required',
            'destination' => 'required',
            'destination_name' => 'required'
        ]);

        return $request->user()->trips()->create($request->only([
            'origin',
            'destination',
            'destination_name'
        ]));

        TripCreated::dispatch($trip, $request->user());
        return $trip;
    }

    public function show(Request $request, Trip $trip)
    {
        // Ensure the user is authenticated
        if (!$request->user()) {
            return response()->json(['message' => 'User is not authenticated.'], 401);
        }
    
        // If the authenticated user is the user who created the trip, return the trip
        if ($trip->user->id === $request->user()->id) {
            return $trip;
        }
    
        // If the authenticated user is a driver, return the trip
        if ($request->user()->driver) {
            return $trip;
        }
        
        // If the trip is not found for the user, return a 404 response
        return response()->json(['message' => 'Cannot find this trip.'], 404);
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
    } //driver_id nd ada msk
    

    public function start(Request $request, Trip $trip){
        $trip->update([
            'is_started' => true
        ]);
        $trip->load('driver.user');
        TripStarted::dispatch($trip, $request->user());

        return $trip;
    }

    public function end(Request $request, Trip $trip){
        $trip->update([
            'is_completed' => true
        ]);
        $trip->load('driver.user');
        TripEnded::dispatch($trip, $request->user());

        return $trip;
    }

    public function location(Request $request, Trip $trip){
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
}
