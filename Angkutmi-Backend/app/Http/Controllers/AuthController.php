<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        // Validate input
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255', // Use 'name' instead of 'username'
            'phone_number' => 'required|string|unique:users,phone_number', // Ensure it's string for compatibility
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        try {
            // Save the user in the database
            User::create([
                'name' => $request->name, // Updated to 'name'
                'phone_number' => $request->phone_number,
                'password' => Hash::make($request->password),
            ]);
            return 'Register successful';
            // return redirect()->route('login')->with('success', 'Registration successful!');
        } catch (\Exception $e) {
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
         
            // Check if user exists and verify password
            if ($user && Hash::check($request->password, $user->password)) {
                // Store user in session
                Auth::login($user);
    
                return 'Login successful';
                // return redirect()->route('home')->with('success', 'Login successful!');
            }
    
            // Return error for invalid credentials
            return back()->withErrors(['error' => 'Invalid phone number or password.'])->withInput();
        } catch (\Exception $e) {
            // Log and display error
            \Log::error($e->getMessage());
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
