import React from "react";
import { formatINR } from "../utils/formatters";
import { AlertTriangle, Award, ExternalLink } from "lucide-react";

export default function OutliersSection({ outliersData, onSelectEmployee }) {
  if (!outliersData) return null;

  const { top_earners = [], underpaid_stars = [], top_earners_threshold = 0 } = outliersData;

  return (
    <div className="alerts-grid">
      {/* Panel 1: Underpaid Top Performers */}
      <div className="alert-panel">
        <div className="alert-panel-header">
          <AlertTriangle size={20} color="#f59e0b" />
          <div>
            <h3 style={{ fontSize: 15, fontWeight: 700 }}>Retention Risk: Underpaid Top Performers</h3>
            <p style={{ fontSize: 12, color: "#94a3b8" }}>Performance Rating ≥ 4 with Compa-Ratio &lt; 85%</p>
          </div>
        </div>

        <div className="alert-list">
          {underpaid_stars.slice(0, 5).map((emp) => (
            <div
              key={emp.id}
              className="alert-item"
              onClick={() => onSelectEmployee(emp.id)}
              title="Click to view & adjust salary"
            >
              <div className="alert-item-info">
                <h4>{emp.name}</h4>
                <p>{emp.job_title} • {emp.department}</p>
              </div>
              <div className="alert-item-metric">
                <div className="val" style={{ color: "#f87171" }}>
                  {emp.compa_ratio}% Band
                </div>
                <div style={{ fontSize: 11, color: "#94a3b8" }}>{formatINR(emp.salary)}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Panel 2: Top Earners (P99 Outliers) */}
      <div className="alert-panel">
        <div className="alert-panel-header">
          <Award size={20} color="#8b5cf6" />
          <div>
            <h3 style={{ fontSize: 15, fontWeight: 700 }}>Top Earner Outliers (99th Percentile)</h3>
            <p style={{ fontSize: 12, color: "#94a3b8" }}>
              Compensation exceeding {formatINR(top_earners_threshold, true)} threshold
            </p>
          </div>
        </div>

        <div className="alert-list">
          {top_earners.slice(0, 5).map((emp) => (
            <div
              key={emp.id}
              className="alert-item"
              onClick={() => onSelectEmployee(emp.id)}
              title="Click to inspect compensation details"
            >
              <div className="alert-item-info">
                <h4>{emp.name}</h4>
                <p>{emp.job_title} • {emp.department}</p>
              </div>
              <div className="alert-item-metric">
                <div className="val" style={{ color: "#c084fc" }}>
                  {formatINR(emp.salary, true)}
                </div>
                <div style={{ fontSize: 11, color: "#94a3b8" }}>{emp.compa_ratio}% Band</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
