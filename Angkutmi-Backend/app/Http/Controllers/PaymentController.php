<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Trip; // Ensure Trip model is available

class PaymentController extends Controller
{
    public function store(Request $request)
    {
        // Validating input
        $validated = $request->validate([
            'trip_id' => 'required|exists:trips,id', // Validate that trip_id exists in trips table
            'payment_type' => 'required|string' // Validate payment_type is a string
        ]);

        try {
            // Fetch the trip based on the provided trip_id
            $trip = Trip::find($validated['trip_id']);
            if (!$trip) {
                return response()->json(['message' => 'Trip not found'], 404); // Return 404 if the trip doesn't exist
            }

            // Get the price from the trip (replace 'total_price' with 'price' as per your update)
            $price = $trip->price;

            // Create the payment and associate it with the trip
            $payment = Payment::create([
                'trip_id' => $validated['trip_id'], // Associate the trip with the payment
                'price' => $price, // Use the price instead of total_price
                'payment_type' => $validated['payment_type'], // The payment type (e.g., 'ovo', 'cash', etc.)
            ]);

            // Return success response with the payment data and trip_id
            return response()->json([
                'message' => 'Payment created successfully.',
                'data' => $payment, // Return the payment data
                'trip_id' => $payment->trip_id, // Return the trip_id that was associated with the payment
            ], 201);

        } catch (\Exception $e) {
            // Catch any errors and return a generic error response
            return response()->json(['error' => 'An error occurred while creating the payment.'], 500);
        }
    }

    public function show($id)
    {
        // Fetch the payment by its ID
        $payment = Payment::find($id);

        if (!$payment) {
            return response()->json(['message' => 'Payment not found'], 404); // Return 404 if the payment doesn't exist
        }

        // Fetch the related trip
        $trip = Trip::find($payment->trip_id);

        // Return payment and trip details
        return response()->json([
            'payment' => $payment,
            'trip' => $trip ? [
                'id' => $trip->id,
                'price' => $trip->price, // Use price instead of total_price
            ] : null,
        ]);
    }
}
