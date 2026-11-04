<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\BookingAssignment;
use App\Models\HonorPayment;
use Illuminate\Http\Request;

class HonorController extends Controller
{
    private function danaHonor(Booking $booking): float
    {
        $pemasukan = (float) $booking->transactions()->where('jenis', 'pemasukan')->sum('jumlah');
        $pengeluaran = (float) $booking->transactions()->where('jenis', 'pengeluaran')->sum('jumlah');
        $laba = $pemasukan - $pengeluaran;

        $kas = $booking->kas_tipe === 'persen'
            ? max(0, $laba) * ((float) $booking->kas_nilai) / 100
            : (float) $booking->kas_nilai;

        return round(max(0, $laba - $kas), 2);
    }

    private function hasil(Booking $booking)
    {
        $rows = HonorPayment::with('member')
            ->where('booking_id', $booking->id)
            ->get()
            ->sortBy(fn ($h) => $h->member->nama)
            ->values()
            ->map(fn ($h) => [
                'id' => $h->id,
                'member_id' => $h->member_id,
                'nama' => $h->member->nama,
                'jumlah_penampilan' => $h->jumlah_penampilan,
                'jumlah_honor' => (float) $h->jumlah_honor,
                'status_bayar' => $h->status_bayar,
                'tanggal_bayar' => $h->tanggal_bayar,
            ]);

        $dana = $this->danaHonor($booking);
        $total = $rows->sum('jumlah_honor');

        return response()->json([
            'dana_honor' => $dana,
            'total_dibagikan' => $total,
            'selisih' => round($dana - $total, 2),
            'data' => $rows,
        ]);
    }

    public function index(Booking $booking)
    {
        return $this->hasil($booking);
    }

    // Hitung usulan honor berbobot jumlah penampilan
    public function hitung(Booking $booking)
    {
        $penampilan = BookingAssignment::query()
            ->join('booking_dances', 'booking_dances.id', '=', 'booking_assignments.booking_dance_id')
            ->where('booking_dances.booking_id', $booking->id)
            ->selectRaw('booking_assignments.member_id, COUNT(DISTINCT booking_dances.id) as n')
            ->groupBy('booking_assignments.member_id')
            ->pluck('n', 'member_id');

        if ($penampilan->isEmpty()) {
            return response()->json(
                ['message' => 'Belum ada pemain yang ditugaskan di booking ini.'],
                422
            );
        }

        $dana = $this->danaHonor($booking);
        $totalBobot = $penampilan->sum();

        // Yang sudah dibayar tidak ditimpa
        $sudahBayar = HonorPayment::where('booking_id', $booking->id)
            ->where('status_bayar', 'sudah')
            ->pluck('member_id')
            ->all();

        // Hapus usulan lama yang belum dibayar
        HonorPayment::where('booking_id', $booking->id)
            ->where('status_bayar', '!=', 'sudah')
            ->delete();

        foreach ($penampilan as $memberId => $n) {
            if (in_array($memberId, $sudahBayar)) {
                continue;
            }
            HonorPayment::create([
                'booking_id' => $booking->id,
                'member_id' => $memberId,
                'jumlah_penampilan' => $n,
                'jumlah_honor' => round($dana * $n / $totalBobot),
                'status_bayar' => 'belum',
            ]);
        }

        return $this->hasil($booking);
    }

    // Ubah nominal atau status bayar satu pemain
    public function update(Request $request, Booking $booking, HonorPayment $honor)
    {
        if ($honor->booking_id !== $booking->id) {
            return response()->json(['message' => 'Data tidak ditemukan.'], 404);
        }

        $data = $request->validate([
            'jumlah_honor' => 'sometimes|numeric|min:0|max:9999999999',
            'status_bayar' => 'sometimes|in:belum,sudah',
        ]);

        if (isset($data['status_bayar'])) {
            $data['tanggal_bayar'] = $data['status_bayar'] === 'sudah' ? now()->toDateString() : null;
        }

        $honor->update($data);

        return $this->hasil($booking);
    }
}