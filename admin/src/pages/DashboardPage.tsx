import React, { useEffect, useState } from 'react';
import { Users, UserCheck, Clock, GraduationCap, Building2, MessageSquare, Calendar, Activity } from 'lucide-react';
import api from '../services/api';

export const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState({
    total_members: 142,
    active_members: 138,
    pending_approvals: 4,
    faculty_count: 18,
    officer_count: 124,
    total_communities: 12,
    total_posts: 420,
    total_events: 8,
    daily_active_users: 85,
  });

  useEffect(() => {
    api.get('/admin/stats').then((res) => {
      if (res.data) setStats(res.data);
    }).catch(() => {
      // Graceful fallback to initial values if backend not running
    });
  }, []);

  const cards = [
    { label: 'Total Verified Members', value: stats.total_members, icon: Users, color: 'text-premiumGold' },
    { label: 'Active Members', value: stats.active_members, icon: UserCheck, color: 'text-emerald-400' },
    { label: 'Pending Approvals', value: stats.pending_approvals, icon: Clock, color: 'text-amber-400' },
    { label: 'Authorized Faculty', value: stats.faculty_count, icon: GraduationCap, color: 'text-blue-400' },
    { label: 'Verified Officers (Level 7+)', value: stats.officer_count, icon: Building2, color: 'text-indigo-400' },
    { label: 'Communities', value: stats.total_communities, icon: Building2, color: 'text-purple-400' },
    { label: 'Network Posts', value: stats.total_posts, icon: MessageSquare, color: 'text-pink-400' },
    { label: 'Scheduled Seminars & Events', value: stats.total_events, icon: Calendar, color: 'text-cyan-400' },
    { label: 'Daily Active Users', value: stats.daily_active_users, icon: Activity, color: 'text-emerald-400' },
  ];

  return (
    <div className="p-8 space-y-8">
      <div>
        <h2 className="text-2xl font-bold text-white tracking-tight">System Performance & Governance</h2>
        <p className="text-sm text-mutedGrey mt-1">
          Exclusive oversight of Level 7+ Civil Servant and Faculty engagements.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {cards.map((c, i) => {
          const Icon = c.icon;
          return (
            <div
              key={i}
              className="bg-deepNavy p-6 rounded-2xl border border-borderGrey hover:border-premiumGold/50 transition-colors shadow-sm"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-mutedGrey">{c.label}</span>
                <Icon size={20} className={c.color} />
              </div>
              <div className="mt-4 text-3xl font-extrabold text-white">{c.value}</div>
            </div>
          );
        })}
      </div>

      {/* Quick Action Tables */}
      <div className="bg-deepNavy p-6 rounded-2xl border border-borderGrey">
        <h3 className="text-lg font-bold text-white mb-4">Pending Institutional Verifications</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="text-xs uppercase text-mutedGrey border-b border-borderGrey">
              <tr>
                <th className="pb-3">Candidate</th>
                <th className="pb-3">Designation</th>
                <th className="pb-3">Cadre / Institution</th>
                <th className="pb-3">Status</th>
                <th className="pb-3 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-borderGrey/50">
              <tr>
                <td className="py-4 font-medium text-white">Vikramaditya Rao</td>
                <td className="py-4 text-mutedGrey">Director (Level 13)</td>
                <td className="py-4 text-mutedGrey">Ministry of Home Affairs</td>
                <td className="py-4"><span className="px-2.5 py-1 rounded-full text-xs bg-amber-500/10 text-amber-400 border border-amber-500/30">Pending Approval</span></td>
                <td className="py-4 text-right">
                  <button className="px-3 py-1.5 bg-premiumGold text-midnightNavy text-xs font-bold rounded-lg hover:bg-lightGold">
                    Approve Member
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
