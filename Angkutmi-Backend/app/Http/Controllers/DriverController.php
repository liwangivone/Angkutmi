<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Vehicle;
use Illuminate\Support\Facades\Storage;

class DriverController extends Controller
{
    public function show(Request $request)
    {
        try {
            // Get the authenticated user
            $user = $request->user();
    
            // If the user is not authenticated, return an error
            if (!$user) {
                return response()->json(['error' => 'User not authenticated.'], 401);
            }
            
            // Load the associated driver and vehicle information
            $user->load(['driver', 'driver.vehicle']); // This will load the driver and vehicle relations
    
            // Check if the driver exists
            $driver = $user->driver;
            if (!$driver) {
                return response()->json(['error' => 'Driver not found.'], 404);
            }
    
            // Check if the vehicle exists
            $vehicle = $driver->vehicle;
            if (!$vehicle) {
                return response()->json(['error' => 'Vehicle not found.'], 404);
            }

            $body = [
                "user" => [
                    "id_user" => $user->id,
                    "nama_user" => $user->name
                ]
            ];
    
            // Return the user, driver, and vehicle information
            return response()->json(
                $body // Return the vehicle_id
            , 200);
    
        } catch (\Exception $e) {
            // Handle unexpected errors and return a generic message
            return response()->json(['error' => 'An error occurred while fetching the data.'], 500);
        }
    }
    
    

        

    public function update(Request $request)
    {
        // Validate the request data
        $validatedData = $request->validate([
            'type' => 'required|string|in:motor,pickup,truck',
            'capacity' => 'required|integer|min:1',
            'plat' => 'required|string|unique:vehicles,plat',
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);
    
        // Get the authenticated user
        $user = $request->user();
    
        // Create or update the vehicle
        $vehicle = Vehicle::updateOrCreate(
            ['plat' => $validatedData['plat']], // Match by unique plate number
            [
                'type' => $validatedData['type'],
                'capacity' => $validatedData['capacity'],
            ]
        );
        // Check if the vehicle is created successfully
        if (!$vehicle->id) {
            return response()->json(['error' => 'Failed to create or update vehicle.'], 500);
        }
    
        // Handle profile picture upload if present
        $profilePicturePath = null;
        if ($request->hasFile('profile_picture')) {
            $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
        }
    
        // Create or update the driver record linked to the user
        // Ensure that vehicle_id is not null
        $driver = $user->driver()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'vehicle_id' => $vehicle->id, // Make sure this is set
                'profile_picture' => $profilePicturePath,
            ]
        );
    
        return response()->json([
            'message' => 'Driver and vehicle updated successfully.',
            'driver' => $driver,
            'vehicle' => $vehicle,
        ], 200);
    }
        }
