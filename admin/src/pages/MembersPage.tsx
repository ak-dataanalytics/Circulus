import React, { useState } from 'react';
import { Search, CheckCircle2, Ban } from 'lucide-react';

export const MembersPage: React.FC = () => {
  const [members, setMembers] = useState([
    {
      id: '1',
      name: 'Dr. Sunil Mehta',
      email: 'sunil.mehta@gov.in',
      designation: 'Joint Secretary (Level 14)',
      department: 'Department of Public Policy',
      status: 'pending',
    },
    {
      id: '2',
      name: 'Ananya Verma',
      email: 'ananya.verma@circulus.app',
      designation: 'Deputy Secretary (Level 12)',
      department: 'Ministry of Finance',
      status: 'verified',
    },
    {
      id: '3',
      name: 'Prof. Rajesh Sharma',
      email: 'dr.sharma@circulus.app',
      designation: 'Professor of Public Policy',
      department: 'National Academy of Administration',
      status: 'verified',
    },
  ]);

  const handleVerify = (id: string) => {
    setMembers((prev) =>
      prev.map((m) => (m.id === id ? { ...m, status: 'verified' } : m))
    );
  };

  return (
    <div className="p-8 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white">Member Directory & Approvals</h2>
          <p className="text-sm text-mutedGrey">Approve or suspend officer credentials under governance rules.</p>
        </div>
        <div className="relative">
          <Search className="absolute left-3 top-2.5 text-mutedGrey" size={16} />
          <input
            type="text"
            placeholder="Search verified members..."
            className="pl-9 pr-4 py-2 bg-deepNavy border border-borderGrey rounded-xl text-sm text-white placeholder-mutedGrey focus:outline-none focus:border-premiumGold"
          />
        </div>
      </div>

      <div className="bg-deepNavy rounded-2xl border border-borderGrey overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="text-xs uppercase text-mutedGrey bg-midnightNavy/50 border-b border-borderGrey">
            <tr>
              <th className="p-4">Full Name</th>
              <th className="p-4">Official Email</th>
              <th className="p-4">Rank / Designation</th>
              <th className="p-4">Department</th>
              <th className="p-4">Verification</th>
              <th className="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-borderGrey/50">
            {members.map((m) => (
              <tr key={m.id} className="hover:bg-surfaceNavy/40">
                <td className="p-4 font-semibold text-white">{m.name}</td>
                <td className="p-4 text-mutedGrey">{m.email}</td>
                <td className="p-4 text-premiumGold font-medium">{m.designation}</td>
                <td className="p-4 text-mutedGrey">{m.department}</td>
                <td className="p-4">
                  <span
                    className={`px-2.5 py-1 rounded-full text-xs font-semibold ${
                      m.status === 'verified'
                        ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30'
                        : 'bg-amber-500/10 text-amber-400 border border-amber-500/30'
                    }`}
                  >
                    {m.status.toUpperCase()}
                  </span>
                </td>
                <td className="p-4 text-right space-x-2">
                  {m.status === 'pending' && (
                    <button
                      onClick={() => handleVerify(m.id)}
                      className="px-3 py-1 bg-emerald-500 text-midnightNavy text-xs font-bold rounded-lg hover:bg-emerald-400"
                    >
                      Approve
                    </button>
                  )}
                  <button className="px-3 py-1 bg-surfaceNavy text-mutedGrey hover:text-red-400 text-xs font-semibold rounded-lg border border-borderGrey">
                    Suspend
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
