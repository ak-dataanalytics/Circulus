import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Users, Mail, ShieldAlert, FileText, Settings, Award } from 'lucide-react';

export const Sidebar: React.FC = () => {
  const links = [
    { to: '/', label: 'Overview', icon: LayoutDashboard },
    { to: '/members', label: 'Member Verifications', icon: Users },
    { to: '/invitations', label: 'Invitation Codes', icon: Mail },
    { to: '/moderation', label: 'Content Moderation', icon: ShieldAlert },
    { to: '/leaderboard', label: 'Podiums & Competitions', icon: Award },
    { to: '/audit-logs', label: 'Audit Trail', icon: FileText },
  ];

  return (
    <aside className="w-64 bg-deepNavy border-r border-borderGrey flex flex-col h-screen sticky top-0">
      <div className="p-6 border-b border-borderGrey flex items-center space-x-3">
        <div className="w-9 h-9 rounded-full border border-premiumGold bg-midnightNavy flex items-center justify-center font-bold text-premiumGold">
          C
        </div>
        <div>
          <h1 className="text-lg font-bold tracking-widest text-white">CIRCULUS</h1>
          <p className="text-xs text-premiumGold tracking-wider">ADMIN PORTAL</p>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {links.map((link) => {
          const Icon = link.icon;
          return (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) =>
                `flex items-center space-x-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-midnightNavy text-premiumGold border border-borderGrey'
                    : 'text-mutedGrey hover:text-white hover:bg-surfaceNavy'
                }`
              }
            >
              <Icon size={18} />
              <span>{link.label}</span>
            </NavLink>
          );
        })}
      </nav>
      <div className="p-4 border-t border-borderGrey">
        <div className="px-4 py-3 rounded-xl bg-midnightNavy border border-borderGrey flex items-center justify-between">
          <div>
            <p className="text-xs font-semibold text-white">Super Administrator</p>
            <p className="text-[11px] text-mutedGrey">admin@circulus.app</p>
          </div>
        </div>
      </div>
    </aside>
  );
};
