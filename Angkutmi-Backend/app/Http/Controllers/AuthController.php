<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        // Validate input
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'phone_number' => 'required|string|unique:users,phone_number',
            'password' => 'required|string|min:6',
        ]);
    
        if ($validator->fails()) {
            // Return validation errors as JSON
            return response()->json(['error' => $validator->errors()], 422);
        }
    
        try {
            // Save the user in the database
            User::create([
                'name' => $request->name,
                'phone_number' => $request->phone_number,
                'password' => Hash::make($request->password),
            ]);
            
            // Return success as JSON
            return response()->json(['success' => true, 'message' => 'Registration successful'], 200);
        } catch (\Exception $e) {
            // Return exception error as JSON
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    


    // Fitur Login
    public function login(Request $request)
    {
        // Validate input
        $request->validate([
            'phone_number' => 'required|string',
            'password' => 'required|string',
        ]);
    
        try {
            // Attempt to find the user by phone number
            $user = User::where('phone_number', $request->phone_number)->first();
    
            // Log user for debugging
            Log::info('User found: ', [$user]);
    
            // Check if user exists and verify password
            if ($user && Hash::check($request->password, $user->password)) {
                // Generate and return token
                $token = $user->createToken('auth_token')->plainTextToken;
    
                // Return successful login response with the token
                return response()->json([
                    'success' => true,
                    'message' => 'Login successful',
                    'user' => $user,
                    'token' => $token,
                    // Uncomment the next line if you want to return user data too
                    // 'user' => $user,  
                ], 200);
            }    
    
            // Return error for invalid credentials
            return response()->json(['error' => 'Invalid phone number or password.'], 401);
        } catch (\Exception $e) {
            // Log and display error
            Log::error($e->getMessage());
            return response()->json(['error' => 'An unexpected error occurred.'], 500);
        }
    }
            
    // Logout
    public function logout()
    {
        session()->forget('user');

        return redirect()->route('login')->with('success', 'You have been logged out.');
    }
}
