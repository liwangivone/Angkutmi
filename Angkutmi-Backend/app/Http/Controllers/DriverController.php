<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Vehicle;
use Illuminate\Support\Facades\Storage;

class DriverController extends Controller
{
    public function show(Request $request)
    {
        // Get the authenticated user
        $user = $request->user();
    
        // Load the associated driver and vehicle information
        $user->load(['driver', 'driver.vehicle']); // Ensure the relationship exists
    
        return response()->json([
            'user' => $user,
            'driver' => $user->driver,
            'vehicle' => $user->driver ? $user->driver->vehicle : null, // Load the vehicle associated with the driver
        ], 200);
    }
        

    public function update(Request $request)
    {
        // Validate the incoming request data, including vehicle and profile picture
        $request->validate([
            'type' => 'required|string', // Vehicle type (e.g., sedan, truck)
            'capacity' => 'required|numeric', // Vehicle capacity (e.g., 4 passengers, 2 tons)
            'plat' => 'required|string|unique:vehicles,plat', // Vehicle plate number
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // Profile picture validation
        ]);

        // Get the authenticated user
        $user = $request->user();

        // Update the user's personal details (e.g., name, etc.)
        $user->update($request->only('name'));

        // Create or update the vehicle details
        $vehicle = Vehicle::updateOrCreate(
            ['vehicle_id' => $request->vehicle_id], // Check for existing vehicle or create a new one
            [
                'type' => $request->type,
                'capacity' => $request->capacity,
                'plat' => $request->plat, // Unique plate number
            ]
        );

        // Handle profile picture upload if provided
        $profilePicturePath = null;
        if ($request->hasFile('profile_picture')) {
            $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public'); // Store in public disk
        }

        // Update the driver's details (link driver to updated vehicle and save profile picture)
        $driver = $user->driver()->updateOrCreate(
            ['user_id' => $user->id], // Ensure we create/update the driver related to the user
            [
                'vehicle_id' => $vehicle->vehicle_id, // Associate the driver with the updated vehicle
                'profile_picture' => $profilePicturePath, // Store the profile picture path
            ]
        );

        // Load updated driver and vehicle information
        $user->load('driver.vehicle');

        return response()->json([
            'message' => 'Driver and vehicle information updated successfully.',
            'user' => $user,
            'driver' => $driver,
            'vehicle' => $vehicle,
            'profile_picture' => $profilePicturePath ? asset('storage/' . $profilePicturePath) : null, // Return URL of the profile picture
        ], 200);
    }
}
