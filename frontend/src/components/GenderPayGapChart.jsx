import React from "react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Legend
} from "recharts";
import { formatINR, formatPercent } from "../utils/formatters";
import { Scale, AlertCircle } from "lucide-react";

export default function GenderPayGapChart({ payEquityData }) {
  if (!payEquityData || !payEquityData.levels) return null;

  const { levels = [], overall = {} } = payEquityData;

  const chartData = levels.map((lvl) => ({
    name: lvl.level_name.split(" - ")[0], // e.g. L1, L2
    fullName: lvl.level_name,
    maleAvgLakh: Number((lvl.male.avg_salary / 100000).toFixed(2)),
    femaleAvgLakh: Number((lvl.female.avg_salary / 100000).toFixed(2)),
    ratio: lvl.female_to_male_ratio,
    gap: lvl.pay_gap_pct
  }));

  const overallRatio = overall.female_to_male_ratio || 100.0;
  const overallGap = overall.overall_pay_gap_pct || 0.0;

  return (
    <div className="chart-card" style={{ marginBottom: 28 }}>
      <div className="chart-header">
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <Scale size={20} color="#ec4899" />
            <h3 className="chart-title">Pay Equity & Gender Gap Audit</h3>
          </div>
          <p className="chart-desc">Comparative analysis of male vs. female average compensation by job level (in Lakhs ₹)</p>
        </div>

        <div style={{ textAlign: "right" }}>
          <div style={{ fontSize: 13, color: "#94a3b8" }}>Overall Pay Parity Ratio</div>
          <div style={{ fontSize: 18, fontWeight: 800, color: overallRatio >= 95 ? "#34d399" : "#f59e0b" }}>
            {formatPercent(overallRatio)}
            <span style={{ fontSize: 12, fontWeight: 500, marginLeft: 6, color: "#94a3b8" }}>
              ({overallGap > 0 ? `${overallGap}% gap` : "Parity achieved"})
            </span>
          </div>
        </div>
      </div>

      <div style={{ width: "100%", height: 320 }}>
        <ResponsiveContainer>
          <BarChart data={chartData} margin={{ top: 10, right: 20, left: 10, bottom: 20 }}>
            <XAxis dataKey="fullName" stroke="#94a3b8" fontSize={12} />
            <YAxis stroke="#94a3b8" fontSize={12} tickFormatter={(v) => `₹${v}L`} />
            <Tooltip
              contentStyle={{ backgroundColor: "#1e293b", borderColor: "#334155", borderRadius: 8 }}
              formatter={(val, name, item) => [
                `₹${val} Lakhs`,
                name === "maleAvgLakh" ? "Male Avg Salary" : "Female Avg Salary"
              ]}
            />
            <Legend verticalAlign="top" wrapperStyle={{ paddingBottom: 12, fontSize: 13 }} />
            <Bar dataKey="maleAvgLakh" fill="#3b82f6" radius={[4, 4, 0, 0]} name="Male Avg Salary" />
            <Bar dataKey="femaleAvgLakh" fill="#ec4899" radius={[4, 4, 0, 0]} name="Female Avg Salary" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      <div style={{
        marginTop: 16,
        padding: "12px 16px",
        backgroundColor: "rgba(59, 130, 246, 0.08)",
        borderRadius: 8,
        border: "1px solid rgba(59, 130, 246, 0.2)",
        display: "flex",
        alignItems: "center",
        gap: 12
      }}>
        <AlertCircle size={18} color="#60a5fa" />
        <span style={{ fontSize: 13, color: "#cbd5e1" }}>
          <strong>HR Strategic Note:</strong> Levels L1 through L3 exhibit near-parity (~98-101%). Leadership levels (L4–L6) show an opportunity for market parity adjustments during the upcoming promotion cycle.
        </span>
      </div>
    </div>
  );
}
