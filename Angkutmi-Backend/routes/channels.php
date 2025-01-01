<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\User;
use App\Models\Trip;

Broadcast::channel('drivers', function ($user) {
    // Authorize if the user is a driver (you might have a driver role or similar check)
    return $user->is_driver; // Adjust this check based on your actual driver logic
});

Broadcast::channel('trip_{id}', function ($user, $id) {
    // Authorize if the user is the driver or passenger of the trip
    $trip = Trip::find($id);
    return $trip && ($trip->driver_id === $user->id || $trip->passenger_id === $user->id);
});

Broadcast::channel('passenger_{id}', function ($user, $id) {
    // Authorize if the user is the passenger with this ID
    return (int) $user->id === (int) $id;
});
