import React from "react";
import { Building2, IndianRupee, UserCheck, ShieldCheck } from "lucide-react";

export default function Header({ totalHeadcount = 10000 }) {
  return (
    <header className="app-header">
      <div className="header-inner">
        <div className="brand-section">
          <div className="brand-logo">
            <Building2 size={22} />
          </div>
          <div>
            <div className="brand-title">ACME Org • Compensation Management</div>
            <div className="brand-subtitle">Strategic HR Salary Platform</div>
          </div>
        </div>

        <div className="header-badges">
          <div className="badge-inr">
            <IndianRupee size={14} />
            <span>Base Currency: INR (₹)</span>
          </div>

          <div className="persona-badge">
            <UserCheck size={16} color="#3b82f6" />
            <span>Sarah Chen (HR Director)</span>
          </div>
        </div>
      </div>
    </header>
  );
}
