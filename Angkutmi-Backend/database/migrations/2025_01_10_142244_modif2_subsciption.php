<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if the 'subscriptions' table has the required columns
        if (!Schema::hasColumn('subscriptions', 'package_name')) {
            Schema::table('subscriptions', function (Blueprint $table) {
                $table->string('package_name')->after('user_id')->nullable();
            });
        }

        if (!Schema::hasColumn('subscriptions', 'price')) {
            Schema::table('subscriptions', function (Blueprint $table) {
                $table->decimal('price', 10, 2)->after('package_name');
            });
        }

        if (!Schema::hasColumn('subscriptions', 'address')) {
            Schema::table('subscriptions', function (Blueprint $table) {
                $table->json('address')->after('price');
            });
        }

        if (!Schema::hasColumn('subscriptions', 'schedule_date')) {
            Schema::table('subscriptions', function (Blueprint $table) {
                $table->date('schedule_date')->after('address');
            });
        }

        if (!Schema::hasColumn('subscriptions', 'tpa_id')) {
            Schema::table('subscriptions', function (Blueprint $table) {
                $table->unsignedBigInteger('tpa_id')->after('schedule_date');

                // Add foreign key constraint for tpa_id referencing the TpaLocation table
                $table->foreign('tpa_id')->references('id')->on('tpa_locations')->onDelete('cascade');
            });
        }

        // Check if the 'payments' table already exists
        if (!Schema::hasTable('payments')) {
            // Create the payments table if it doesn't exist
            Schema::create('payments', function (Blueprint $table) {
                $table->id(); // Primary key
                $table->unsignedBigInteger('subscription_id'); // Foreign key referencing the subscriptions table
                $table->string('payment_method'); // Store payment method
                $table->string('status')->default('pending'); // Payment status (pending, success)
                $table->timestamps();

                // Define foreign key constraint
                $table->foreign('subscription_id')->references('id')->on('subscriptions')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop the 'payments' table if it exists
        if (Schema::hasTable('payments')) {
            Schema::dropIfExists('payments');
        }

        // Remove columns from 'subscriptions' table if they exist
        Schema::table('subscriptions', function (Blueprint $table) {
            if (Schema::hasColumn('subscriptions', 'package_name')) {
                $table->dropColumn('package_name');
            }

            if (Schema::hasColumn('subscriptions', 'price')) {
                $table->dropColumn('price');
            }

            if (Schema::hasColumn('subscriptions', 'address')) {
                $table->dropColumn('address');
            }

            if (Schema::hasColumn('subscriptions', 'schedule_date')) {
                $table->dropColumn('schedule_date');
            }

            if (Schema::hasColumn('subscriptions', 'tpa_id')) {
                $table->dropForeign(['tpa_id']);
                $table->dropColumn('tpa_id');
            }
        });
    }
};
