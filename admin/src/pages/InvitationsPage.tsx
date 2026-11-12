import React, { useState } from 'react';
import { Plus, Key, Copy, Check } from 'lucide-react';
import api from '../services/api';

export const InvitationsPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('officer');
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  const [invitations, setInvitations] = useState([
    {
      id: 'inv-1',
      code: 'CIRCULUS2026',
      email: 'officer.test@circulus.app',
      role: 'Officer',
      status: 'pending',
      max_uses: 5,
      use_count: 1,
      expires: '30 Days Left',
    },
    {
      id: 'inv-2',
      code: 'FACULTY-ACADEMY-77',
      email: 'faculty.advisor@circulus.app',
      role: 'Faculty',
      status: 'accepted',
      max_uses: 1,
      use_count: 1,
      expires: 'Claimed',
    },
  ]);

  const handleGenerate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;

    const newCode = `CIR-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
    const newInv = {
      id: `inv-${Date.now()}`,
      code: newCode,
      email: email,
      role: role === 'officer' ? 'Officer' : 'Faculty',
      status: 'pending',
      max_uses: 1,
      use_count: 0,
      expires: '72 Hours',
    };

    setInvitations([newInv, ...invitations]);
    setEmail('');
  };

  const copyToClipboard = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCode(code);
    setTimeout(() => setCopiedCode(null), 2000);
  };

  return (
    <div className="p-8 space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-white">Invitation Code Generator</h2>
        <p className="text-sm text-mutedGrey">CIRCULUS is strictly invitation-only. Issue controlled codes to verified officers or faculty.</p>
      </div>

      {/* Code Generation Form */}
      <form onSubmit={handleGenerate} className="bg-deepNavy p-6 rounded-2xl border border-borderGrey flex flex-wrap items-end gap-4">
        <div className="flex-1 min-w-[240px]">
          <label className="block text-xs uppercase font-semibold text-mutedGrey mb-2">Recipient Official Email</label>
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="officer@nic.in or officer@gov.in"
            className="w-full px-4 py-2.5 bg-midnightNavy border border-borderGrey rounded-xl text-sm text-white placeholder-mutedGrey focus:outline-none focus:border-premiumGold"
          />
        </div>
        <div className="w-48">
          <label className="block text-xs uppercase font-semibold text-mutedGrey mb-2">Role Eligibility</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full px-4 py-2.5 bg-midnightNavy border border-borderGrey rounded-xl text-sm text-white focus:outline-none focus:border-premiumGold"
          >
            <option value="officer">Verified Officer (L7+)</option>
            <option value="faculty">Authorized Faculty</option>
            <option value="admin">Administrator</option>
          </select>
        </div>
        <button
          type="submit"
          className="px-6 py-2.5 bg-premiumGold text-midnightNavy text-sm font-bold rounded-xl hover:bg-lightGold flex items-center space-x-2"
        >
          <Key size={16} />
          <span>GENERATE KEY</span>
        </button>
      </form>

      {/* Invitations Table */}
      <div className="bg-deepNavy rounded-2xl border border-borderGrey overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="text-xs uppercase text-mutedGrey bg-midnightNavy/50 border-b border-borderGrey">
            <tr>
              <th className="p-4">Invitation Code</th>
              <th className="p-4">Assigned Email</th>
              <th className="p-4">Role Tier</th>
              <th className="p-4">Usage</th>
              <th className="p-4">Validity</th>
              <th className="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-borderGrey/50">
            {invitations.map((inv) => (
              <tr key={inv.id} className="hover:bg-surfaceNavy/40">
                <td className="p-4 font-mono font-bold text-premiumGold">{inv.code}</td>
                <td className="p-4 text-white">{inv.email}</td>
                <td className="p-4 text-mutedGrey">{inv.role}</td>
                <td className="p-4 text-mutedGrey">{inv.use_count} / {inv.max_uses}</td>
                <td className="p-4 text-mutedGrey">{inv.expires}</td>
                <td className="p-4 text-right">
                  <button
                    onClick={() => copyToClipboard(inv.code)}
                    className="px-3 py-1.5 bg-surfaceNavy border border-borderGrey rounded-lg text-xs font-semibold text-mutedGrey hover:text-white inline-flex items-center space-x-1"
                  >
                    {copiedCode === inv.code ? <Check size={14} className="text-emerald-400" /> : <Copy size={14} />}
                    <span>{copiedCode === inv.code ? 'COPIED' : 'COPY'}</span>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
