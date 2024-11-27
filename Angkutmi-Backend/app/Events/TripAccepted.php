<?php

namespace App\Events;

use App\Models\Trip; // Import the Trip model
use App\Models\User; // Import the User model
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class TripAccepted
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $trip;
    private $user;

    /**
     * Create a new event instance.
     */
    public function __construct(Trip $trip, User $user)
    {
        $this->trip = $trip;
        $this->user = $user;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        // Broadcasting on a public channel with the trip ID (or any identifier you'd prefer)
        return [
            new Channel('trip_' . $this->trip->id) // Use trip ID or another identifier
        ];
    }
}
