import React from "react";
import { formatINR, formatPercent } from "../utils/formatters";
import { IndianRupee, Users, Target, TrendingUp } from "lucide-react";

export default function StatCards({ summary, loading }) {
  if (loading || !summary) {
    return (
      <div className="kpi-grid">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="kpi-card">
            <div className="spinner" style={{ width: 24, height: 24 }} />
          </div>
        ))}
      </div>
    );
  }

  const {
    total_headcount = 0,
    total_payroll = 0,
    mean_salary = 0,
    median_salary = 0,
    avg_compa_ratio = 100,
    total_bonus_pool = 0
  } = summary;

  return (
    <div className="kpi-grid">
      {/* KPI 1: Total Payroll */}
      <div className="kpi-card">
        <div className="kpi-header">
          <span className="kpi-label">Total Annual Payroll</span>
          <div className="kpi-icon-wrap" style={{ backgroundColor: "rgba(59, 130, 246, 0.15)", color: "#60a5fa" }}>
            <IndianRupee size={20} />
          </div>
        </div>
        <div className="kpi-value">{formatINR(total_payroll, true)}</div>
        <div className="kpi-subtext">Exact: {formatINR(total_payroll)}</div>
      </div>

      {/* KPI 2: Median & Mean Salary */}
      <div className="kpi-card">
        <div className="kpi-header">
          <span className="kpi-label">Median Annual Salary</span>
          <div className="kpi-icon-wrap" style={{ backgroundColor: "rgba(16, 185, 129, 0.15)", color: "#34d399" }}>
            <TrendingUp size={20} />
          </div>
        </div>
        <div className="kpi-value">{formatINR(median_salary, true)}</div>
        <div className="kpi-subtext">Mean: {formatINR(mean_salary, true)} (P50 Database Percentile)</div>
      </div>

      {/* KPI 3: Avg Compa-Ratio */}
      <div className="kpi-card">
        <div className="kpi-header">
          <span className="kpi-label">Org Compa-Ratio</span>
          <div className="kpi-icon-wrap" style={{ backgroundColor: "rgba(245, 158, 11, 0.15)", color: "#fbbf24" }}>
            <Target size={20} />
          </div>
        </div>
        <div className="kpi-value">{formatPercent(avg_compa_ratio)}</div>
        <div className="kpi-subtext">Target Benchmark Band: 80.0% – 120.0%</div>
      </div>

      {/* KPI 4: Total Headcount */}
      <div className="kpi-card">
        <div className="kpi-header">
          <span className="kpi-label">Active Headcount</span>
          <div className="kpi-icon-wrap" style={{ backgroundColor: "rgba(139, 92, 246, 0.15)", color: "#c084fc" }}>
            <Users size={20} />
          </div>
        </div>
        <div className="kpi-value">{total_headcount.toLocaleString("en-IN")}</div>
        <div className="kpi-subtext">Bonus Pool: {formatINR(total_bonus_pool, true)}</div>
      </div>
    </div>
  );
}
