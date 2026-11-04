<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    // Ringkasan keuangan satu booking
    private function ringkasan(Booking $booking): array
    {
        $pemasukan = (float) $booking->transactions()->where('jenis', 'pemasukan')->sum('jumlah');
        $pengeluaran = (float) $booking->transactions()->where('jenis', 'pengeluaran')->sum('jumlah');
        $laba = $pemasukan - $pengeluaran;

        $kas = $booking->kas_tipe === 'persen'
            ? max(0, $laba) * ((float) $booking->kas_nilai) / 100
            : (float) $booking->kas_nilai;

        return [
            'total_biaya' => (float) $booking->total_biaya,
            'pemasukan' => $pemasukan,
            'sisa_tagihan' => max(0, (float) $booking->total_biaya - $pemasukan),
            'pengeluaran' => $pengeluaran,
            'laba_kotor' => $laba,
            'kas_tipe' => $booking->kas_tipe,
            'kas_nilai' => (float) $booking->kas_nilai,
            'kas' => round($kas, 2),
            'dana_honor' => round(max(0, $laba - $kas), 2),
        ];
    }

    // Status otomatis mengikuti pembayaran (kecuali selesai / batal)
    private function updateStatus(Booking $booking): void
    {
        if (in_array($booking->status, ['selesai', 'batal'])) {
            return;
        }
        $bayar = (float) $booking->transactions()->where('jenis', 'pemasukan')->sum('jumlah');
        $total = (float) $booking->total_biaya;

        if ($total > 0 && $bayar >= $total) {
            $booking->update(['status' => 'lunas']);
        } elseif ($bayar > 0) {
            $booking->update(['status' => 'dp']);
        } else {
            $booking->update(['status' => 'menunggu']);
        }
    }

    public function index(Booking $booking)
    {
        return response()->json([
            'transaksi' => $booking->transactions()->orderBy('tanggal')->orderBy('id')->get(),
            'ringkasan' => $this->ringkasan($booking),
        ]);
    }

    public function store(Request $request, Booking $booking)
    {
        $data = $request->validate([
            'jenis' => 'required|in:pemasukan,pengeluaran',
            'keterangan' => 'nullable|string|max:255',
            'jumlah' => 'required|numeric|min:1|max:9999999999',
            'tanggal' => 'required|date',
        ]);

        $booking->transactions()->create($data);
        $this->updateStatus($booking->fresh());

        return response()->json($this->index($booking->fresh())->getData(), 201);
    }

    public function destroy(Booking $booking, Transaction $transaction)
    {
        if ($transaction->booking_id !== $booking->id) {
            return response()->json(['message' => 'Transaksi tidak ditemukan.'], 404);
        }
        $transaction->delete();
        $this->updateStatus($booking->fresh());

        return response()->json($this->index($booking->fresh())->getData());
    }

    // Atur kas per job
    public function updateKas(Request $request, Booking $booking)
    {
        $data = $request->validate([
            'kas_tipe' => 'required|in:nominal,persen',
            'kas_nilai' => 'required|numeric|min:0|max:9999999999',
        ]);
        if ($data['kas_tipe'] === 'persen' && $data['kas_nilai'] > 100) {
            return response()->json(['message' => 'Persentase maksimal 100.'], 422);
        }

        $booking->update($data);

        return response()->json($this->index($booking->fresh())->getData());
    }
}