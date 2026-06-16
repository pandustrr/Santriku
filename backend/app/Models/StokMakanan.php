<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StokMakanan extends Model
{
    protected $table = 'stok_makanans';

    protected $fillable = [
        'tanggal',
        'jenis_makan',
        'porsi_total',
    ];
}
