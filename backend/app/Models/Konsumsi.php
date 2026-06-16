<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Konsumsi extends Model
{
    protected $fillable = [
        'santri_id',
        'pengurus_id',
        'jenis_makan',
        'tanggal',
        'waktu_ambil',
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class);
    }

    public function pengurus()
    {
        return $this->belongsTo(User::class, 'pengurus_id');
    }
}
