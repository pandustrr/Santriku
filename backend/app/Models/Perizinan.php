<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Perizinan extends Model
{
    protected $table = 'perizinans';

    protected $fillable = [
        'santri_id',
        'wali_id',
        'jenis_izin',
        'tanggal_mulai',
        'tanggal_selesai',
        'alasan',
        'bukti_path',
        'status',
        'approved_by',
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class);
    }

    public function wali()
    {
        return $this->belongsTo(User::class, 'wali_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
