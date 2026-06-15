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
        Schema::create('absensis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('santri_id')->constrained('santris')->onDelete('cascade');
            $table->foreignId('pengurus_id')->constrained('users')->onDelete('cascade');
            $table->string('status'); // e.g. Hadir, Sakit, Izin, Alpa
            $table->double('latitude');
            $table->double('longitude');
            $table->boolean('is_in_range');
            $table->timestamp('waktu_absen')->useCurrent();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absensis');
    }
};
