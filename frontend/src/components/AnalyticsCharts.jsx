import React from "react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from "recharts";
import { formatINR } from "../utils/formatters";

const PIE_COLORS = ["#ef4444", "#10b981", "#8b5cf6"];

export default function AnalyticsCharts({ departments = [], distribution = [], locations = [] }) {
  // Prepare Department data for chart
  const deptData = departments.map((d) => ({
    name: d.name,
    total_salary_cr: Number((d.total_salary / 10000000).toFixed(2)),
    headcount: d.headcount,
    avg_salary_lakh: Number((d.avg_salary / 100000).toFixed(2))
  }));

  // Prepare Compa Distribution data
  const distData = distribution.map((d) => ({
    name: d.bracket,
    value: d.count,
    percentage: d.percentage
  }));

  // Prepare Location data
  const locData = locations.map((l) => ({
    city: l.city,
    country: l.country,
    headcount: l.headcount,
    total_spend_cr: Number((l.total_salary / 10000000).toFixed(2))
  }));

  return (
    <div>
      <div className="charts-grid">
        {/* Chart 1: Department Spend & Headcount */}
        <div className="chart-card">
          <div className="chart-header">
            <div>
              <h3 className="chart-title">Payroll Allocation by Department</h3>
              <p className="chart-desc">Total Salary Expenditure in Crores (₹ Cr)</p>
            </div>
          </div>
          <div style={{ width: "100%", height: 320 }}>
            <ResponsiveContainer>
              <BarChart data={deptData} margin={{ top: 10, right: 20, left: 10, bottom: 40 }}>
                <XAxis
                  dataKey="name"
                  stroke="#94a3b8"
                  fontSize={11}
                  interval={0}
                  angle={-25}
                  textAnchor="end"
                />
                <YAxis stroke="#94a3b8" fontSize={12} tickFormatter={(v) => `₹${v}Cr`} />
                <Tooltip
                  contentStyle={{ backgroundColor: "#1e293b", borderColor: "#334155", borderRadius: 8 }}
                  formatter={(value, name) => [
                    name === "total_salary_cr" ? `₹${value} Cr` : value,
                    name === "total_salary_cr" ? "Total Payroll" : name
                  ]}
                />
                <Bar dataKey="total_salary_cr" fill="#3b82f6" radius={[4, 4, 0, 0]} name="Total Spend" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Chart 2: Compa-Ratio Distribution */}
        <div className="chart-card">
          <div className="chart-header">
            <div>
              <h3 className="chart-title">Compensation Band Health</h3>
              <p className="chart-desc">Employees vs Midpoint Benchmark (Compa-Ratio)</p>
            </div>
          </div>
          <div style={{ width: "100%", height: 320 }}>
            <ResponsiveContainer>
              <PieChart>
                <Pie
                  data={distData}
                  cx="50%"
                  cy="50%"
                  innerRadius={70}
                  outerRadius={105}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {distData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ backgroundColor: "#1e293b", borderColor: "#334155", borderRadius: 8 }}
                  formatter={(value, name, item) => [
                    `${value.toLocaleString("en-IN")} employees (${item.payload.percentage}%)`,
                    item.payload.name
                  ]}
                />
                <Legend
                  verticalAlign="bottom"
                  wrapperStyle={{ paddingTop: 16, fontSize: 12, color: "#94a3b8" }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Location Breakdown Bar Chart */}
      <div className="chart-card" style={{ marginBottom: 28 }}>
        <div className="chart-header">
          <div>
            <h3 className="chart-title">Global Office Presence & Compensation</h3>
            <p className="chart-desc">Headcount and Total Expenditure across regional centers</p>
          </div>
        </div>
        <div style={{ width: "100%", height: 260 }}>
          <ResponsiveContainer>
            <BarChart data={locData} margin={{ top: 10, right: 20, left: 10, bottom: 20 }}>
              <XAxis dataKey="city" stroke="#94a3b8" fontSize={12} />
              <YAxis stroke="#94a3b8" fontSize={12} tickFormatter={(v) => `₹${v}Cr`} />
              <Tooltip
                contentStyle={{ backgroundColor: "#1e293b", borderColor: "#334155", borderRadius: 8 }}
                formatter={(val, name) => [
                  name === "total_spend_cr" ? `₹${val} Cr` : val,
                  name === "total_spend_cr" ? "Total Expenditure" : "Headcount"
                ]}
              />
              <Bar dataKey="total_spend_cr" fill="#8b5cf6" radius={[4, 4, 0, 0]} name="Total Spend (₹ Cr)" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
}
