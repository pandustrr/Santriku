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
        Schema::create('stok_makanans', function (Blueprint $table) {
            $table->id();
            $table->date('tanggal');
            $table->string('jenis_makan'); // Sarapan, Siang, Malam
            $table->integer('porsi_total');
            $table->timestamps();

            $table->unique(['tanggal', 'jenis_makan']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stok_makanans');
    }
};
