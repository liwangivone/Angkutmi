<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Vehicle;
use App\Models\Driver; 
use Illuminate\Support\Facades\Storage;

class DriverController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/driver/create",
     *     summary="Create a new driver",
     *     description="Create a new driver with associated vehicle details.",
     *     tags={"Driver"},
     *     security={{"bearerAuth":{}}}
     * )
     */
    public function createDriver(Request $request)
    {
        $validatedData = $request->validate([
            'type' => 'required|string|in:motor,pickup,truck',
            'model' => 'required|string',
            'plat' => 'required|string|unique:vehicles,plat',
            'profile_picture' => 'nullable|string',
        ]);

        try {
            $user = $request->user();

            $vehicle = Vehicle::create([
                'type' => $validatedData['type'],
                'model' => $validatedData['model'],
                'plat' => $validatedData['plat'],
            ]);

            $profilePicturePath = null;
            if ($request->hasFile('profile_picture')) {
                $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
            }

            $driver = Driver::create([
                'user_id' => $user->id,
                'vehicle_id' => $vehicle->id,
                'profile_picture' => $profilePicturePath,
            ]);

            return response()->json([
                'message' => 'Driver created successfully.',
                'driver' => $driver,
                'vehicle' => $vehicle,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => 'An error occurred while creating the driver.'], 500);
        }
    }
    /**
     * @OA\Get(
     *     path="/api/driver/show",
     *     summary="Get driver and vehicle details",
     *     description="Retrieve authenticated user's driver and vehicle information.",
     *     tags={"Driver"},
     *     security={{"bearerAuth":{}}}
     * )
     */
    public function showDrivers(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json(['error' => 'User not authenticated.'], 401);
            }

            $user->load(['driver', 'driver.vehicle']);

            $driver = $user->driver;
            if (!$driver) {
                return response()->json(['error' => 'Driver not found.'], 404);
            }

            $vehicle = $driver->vehicle;
            if (!$vehicle) {
                return response()->json(['error' => 'Vehicle not found.'], 404);
            }

            return response()->json([
                'user' => [
                    'id_user' => $user->id,
                    'nama_user' => $user->name,
                ],
                'driver' => $driver,
                'vehicle' => $vehicle,
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'An error occurred while fetching the data.'], 500);
        }
    }

   /**
     * @OA\Post(
     *     path="/api/driver/update",
     *     summary="Update driver and vehicle information",
     *     description="Allows an authenticated user to update their driver profile and associated vehicle details.",
     *     tags={"Driver"},
     *     security={{"bearerAuth":{}}}
     * )
     */
    public function update(Request $request)
    {
        $validatedData = $request->validate([
            'type' => 'required|string|in:motor,pickup,truck',
            'model' => 'required|string',
            'plat' => 'required|string|unique:vehicles,plat',
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $user = $request->user();

        $vehicle = Vehicle::updateOrCreate(
            ['plat' => $validatedData['plat']],
            [
                'type' => $validatedData['type'],
                'model' => $validatedData['model'],
            ]
        );

        if (!$vehicle->id) {
            return response()->json(['error' => 'Failed to create or update vehicle.'], 500);
        }

        $profilePicturePath = null;
        if ($request->hasFile('profile_picture')) {
            $profilePicturePath = $request->file('profile_picture')->store('profile_pictures', 'public');
        }

        $driver = $user->driver()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'vehicle_id' => $vehicle->id,
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
