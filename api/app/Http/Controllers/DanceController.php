<?php

namespace App\Http\Controllers;

use App\Models\Dance;
use Illuminate\Http\Request;

class DanceController extends Controller
{
    private function rules(): array
    {
        return [
            'nama_tari' => 'required|string|max:255',
            'deskripsi' => 'nullable|string',
            'status_aktif' => 'boolean',
            'roles' => 'array',
            'roles.*.role_id' => 'required|exists:roles,id',
            'roles.*.jumlah_orang' => 'required|integer|min:1',
        ];
    }

    private function syncRoles(Dance $dance, array $roles): void
    {
        $sync = [];
        foreach ($roles as $r) {
            $sync[$r['role_id']] = ['jumlah_orang' => $r['jumlah_orang']];
        }
        $dance->roles()->sync($sync);
    }

    public function index()
    {
        return Dance::with('roles')->orderBy('nama_tari')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate($this->rules());

        $dance = Dance::create(collect($data)->except('roles')->toArray());
        $this->syncRoles($dance, $data['roles'] ?? []);

        return response()->json($dance->load('roles'), 201);
    }

    public function show(Dance $dance)
    {
        return $dance->load('roles');
    }

    public function update(Request $request, Dance $dance)
    {
        $data = $request->validate($this->rules());

        $dance->update(collect($data)->except('roles')->toArray());
        if ($request->has('roles')) {
            $this->syncRoles($dance, $data['roles']);
        }

        return $dance->load('roles');
    }

    public function destroy(Dance $dance)
    {
        if ($dance->id && \DB::table('booking_dances')->where('dance_id', $dance->id)->exists()) {
            return response()->json(
                ['message' => 'Tari sudah dipakai di booking. Nonaktifkan saja.'],
                422
            );
        }

        $dance->delete();

        return response()->json(null, 204);
    }
}