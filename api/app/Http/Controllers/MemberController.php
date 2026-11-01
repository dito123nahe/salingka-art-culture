<?php

namespace App\Http\Controllers;

use App\Models\Member;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    public function index()
    {
        return Member::with('roles')->orderBy('nama')->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:255',
            'no_hp' => 'nullable|string|max:20',
            'status_aktif' => 'boolean',
            'role_ids' => 'array',
            'role_ids.*' => 'exists:roles,id',
        ]);

        $member = Member::create(collect($data)->except('role_ids')->toArray());
        $member->roles()->sync($data['role_ids'] ?? []);

        return response()->json($member->load('roles'), 201);
    }

    public function show(Member $member)
    {
        return $member->load('roles');
    }

    public function update(Request $request, Member $member)
    {
        $data = $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'no_hp' => 'nullable|string|max:20',
            'status_aktif' => 'boolean',
            'role_ids' => 'array',
            'role_ids.*' => 'exists:roles,id',
        ]);

        $member->update(collect($data)->except('role_ids')->toArray());
        if ($request->has('role_ids')) {
            $member->roles()->sync($data['role_ids']);
        }

        return $member->load('roles');
    }

    public function destroy(Member $member)
    {
        $member->delete();

        return response()->json(null, 204);
    }
}