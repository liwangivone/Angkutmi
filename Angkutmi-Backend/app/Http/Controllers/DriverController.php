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
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="type", type="string", enum={"motor", "pickup", "truck"}, example="pickup"),
     *             @OA\Property(property="capacity", type="integer", example=100),
     *             @OA\Property(property="plat", type="string", example="D1234ABC"),
     *             @OA\Property(property="profile_picture", type="string", format="binary", description="Driver's profile picture")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Driver created successfully.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Driver created successfully."),
     *             @OA\Property(property="driver", type="object", description="Details of the newly created driver"),
     *             @OA\Property(property="vehicle", type="object", description="Details of the associated vehicle")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Validation error.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="Validation error details.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="An error occurred while creating the driver.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="An error occurred while creating the driver.")
     *         )
     *     )
     * )
     */
    public function createDriver(Request $request)
    {
        $validatedData = $request->validate([
            'type' => 'required|string|in:motor,pickup,truck',
            'capacity' => 'required|integer|min:1',
            'plat' => 'required|string|unique:vehicles,plat',
            'profile_picture' => 'nullable|string',
        ]);

        try {
            $user = $request->user();

            $vehicle = Vehicle::create([
                'type' => $validatedData['type'],
                'capacity' => $validatedData['capacity'],
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
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Successfully retrieved driver and vehicle details.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="user", type="object",
     *                 @OA\Property(property="id_user", type="integer", example=1),
     *                 @OA\Property(property="nama_user", type="string", example="John Doe")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="User not authenticated.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="User not authenticated.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Driver or vehicle not found.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="Driver not found.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="An error occurred while fetching the data.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="An error occurred while fetching the data.")
     *         )
     *     )
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
     *     description="Allows an authenticated user to update their driver profile and associated vehicle details. If a driver or vehicle record does not exist, a new one is created.",
     *     tags={"Driver"},
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"type", "capacity", "plat"},
     *             @OA\Property(property="type", type="string", description="Vehicle type ('motor', 'pickup', or 'truck')", example="motor"),
     *             @OA\Property(property="capacity", type="integer", description="Vehicle capacity (minimum 1)", example=2),
     *             @OA\Property(property="plat", type="string", description="Unique vehicle license plate", example="AB123CD"),
     *             @OA\Property(
     *                 property="profile_picture",
     *                 type="string",
     *                 format="binary",
     *                 description="Profile picture of the driver (image file)"
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Driver and vehicle information updated successfully.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="message", type="string", example="Driver and vehicle information updated successfully."),
     *             @OA\Property(property="driver", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="profile_picture", type="string", example="profile_pictures/driver1.jpg")
     *             ),
     *             @OA\Property(property="vehicle", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="type", type="string", example="motor"),
     *                 @OA\Property(property="capacity", type="integer", example=2),
     *                 @OA\Property(property="plat", type="string", example="AB123CD")
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Validation error.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="The given data was invalid.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="User not authenticated.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="User not authenticated.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Server error occurred during the update process.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="error", type="string", example="An error occurred while updating the driver and vehicle information.")
     *         )
     *     )
     * )
     */
    public function updateDriver(Request $request)
    {
        $validatedData = $request->validate([
            'type' => 'required|string|in:motor,pickup,truck',
            'capacity' => 'required|integer|min:1',
            'plat' => 'required|string|unique:vehicles,plat',
            'profile_picture' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $user = $request->user();

        $vehicle = Vehicle::updateOrCreate(
            ['plat' => $validatedData['plat']],
            [
                'type' => $validatedData['type'],
                'capacity' => $validatedData['capacity'],
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
