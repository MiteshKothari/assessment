import React, { useState, useEffect } from "react";
import { formatINR, formatPercent, formatDate } from "../utils/formatters";
import { X, Check, Clock, TrendingUp, AlertCircle } from "lucide-react";
import { api } from "../services/api";

const REASONS = [
  "Merit Increase",
  "Promotion",
  "Market Adjustment",
  "Retention",
  "Internal Transfer",
  "Annual Review",
  "Probation Completion"
];

export default function EmployeeModal({ employeeId, onClose, onSalaryUpdated }) {
  const [employee, setEmployee] = useState(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  // Form state
  const [newSalary, setNewSalary] = useState("");
  const [reason, setReason] = useState("Merit Increase");
  const [notes, setNotes] = useState("");

  useEffect(() => {
    if (!employeeId) return;
    setLoading(true);
    setError(null);
    setSuccessMsg(null);

    api.getEmployee(employeeId)
      .then((data) => {
        setEmployee(data.employee);
        setNewSalary(data.employee.salary.toString());
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [employeeId]);

  if (!employeeId) return null;

  // Calculate live preview metrics
  const currentSalary = employee ? Number(employee.salary) : 0;
  const targetSalary = Number(newSalary) || 0;
  const midSalary = employee ? Number(employee.job_level_mid_salary) : 0;

  const hikePct = currentSalary > 0 && targetSalary > 0
    ? (((targetSalary - currentSalary) / currentSalary) * 100).toFixed(1)
    : 0;

  const newCompaRatio = midSalary > 0 && targetSalary > 0
    ? ((targetSalary / midSalary) * 100).toFixed(1)
    : 100;

  const handleAdjustSalary = async (e) => {
    e.preventDefault();
    if (!targetSalary || targetSalary <= 0) {
      setError("Please enter a valid salary amount in INR");
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      const response = await api.adjustSalary(employee.id, {
        new_salary: targetSalary,
        change_reason: reason,
        notes: notes
      });

      setSuccessMsg("Salary successfully adjusted!");
      setEmployee(response.employee);
      if (onSalaryUpdated) onSalaryUpdated();
    } catch (err) {
      setError(err.message || "Failed to adjust salary");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div className="modal-header">
          <div>
            <h2 className="modal-title">
              {loading ? "Employee Compensation Details" : `${employee.name} (${employee.employee_code})`}
            </h2>
            {employee && (
              <p style={{ fontSize: 13, color: "var(--text-secondary)" }}>
                {employee.job_title} • {employee.department_name}
              </p>
            )}
          </div>
          <button className="modal-close-btn" onClick={onClose}>
            <X size={20} />
          </button>
        </div>

        {/* Body */}
        <div className="modal-body">
          {loading ? (
            <div className="state-center">
              <div className="spinner" />
              <p>Loading compensation profile...</p>
            </div>
          ) : error && !employee ? (
            <div className="state-center" style={{ color: "#ef4444" }}>
              <AlertCircle size={28} />
              <p>{error}</p>
            </div>
          ) : (
            <>
              {/* Profile Details Card */}
              <div className="profile-card">
                <div className="profile-field">
                  <label>Location & Office</label>
                  <div>{employee.location_city}, {employee.location_country}</div>
                </div>
                <div className="profile-field">
                  <label>Employment Type</label>
                  <div>{employee.employment_type} (Hired {formatDate(employee.hire_date)})</div>
                </div>
                <div className="profile-field">
                  <label>Job Level & Grade</label>
                  <div>{employee.job_level_name}</div>
                </div>
                <div className="profile-field">
                  <label>Performance Rating</label>
                  <div>
                    <span className="rating-stars">{"★".repeat(employee.performance_rating)}</span> ({employee.performance_rating}/5)
                  </div>
                </div>
                <div className="profile-field">
                  <label>Target Bonus %</label>
                  <div>{employee.bonus_percentage}%</div>
                </div>
                <div className="profile-field">
                  <label>Equity Shares</label>
                  <div>{employee.equity_shares.toLocaleString("en-IN")} options</div>
                </div>
              </div>

              {/* Band & Compa-Ratio Health */}
              <div style={{
                backgroundColor: "var(--bg-app)",
                padding: 16,
                borderRadius: 10,
                border: "1px solid var(--border-subtle)"
              }}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8, fontSize: 13 }}>
                  <span>Band Min: <strong>{formatINR(employee.job_level_min_salary, true)}</strong></span>
                  <span>Band Mid: <strong>{formatINR(employee.job_level_mid_salary, true)}</strong></span>
                  <span>Band Max: <strong>{formatINR(employee.job_level_max_salary, true)}</strong></span>
                </div>

                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 8 }}>
                  <span style={{ fontSize: 13, color: "var(--text-secondary)" }}>Current Compa-Ratio:</span>
                  <span style={{
                    fontSize: 16,
                    fontWeight: 800,
                    color: employee.compa_ratio < 80 ? "#f87171" : employee.compa_ratio > 120 ? "#c084fc" : "#34d399"
                  }}>
                    {employee.compa_ratio}%
                  </span>
                </div>
              </div>

              {/* Salary Adjustment Form */}
              <form onSubmit={handleAdjustSalary} style={{
                backgroundColor: "var(--bg-card)",
                padding: 18,
                borderRadius: 10,
                border: "1px solid var(--border-subtle)",
                display: "flex",
                flexDirection: "column",
                gap: 14
              }}>
                <div style={{ display: "flex", alignItems: "center", gap: 8, fontWeight: 700, fontSize: 15 }}>
                  <TrendingUp size={18} color="#3b82f6" />
                  <span>Adjust Annual Compensation (INR)</span>
                </div>

                {successMsg && (
                  <div style={{
                    backgroundColor: "var(--success-bg)",
                    color: "#34d399",
                    padding: "8px 12px",
                    borderRadius: 6,
                    fontSize: 13,
                    display: "flex",
                    alignItems: "center",
                    gap: 8
                  }}>
                    <Check size={16} />
                    <span>{successMsg}</span>
                  </div>
                )}

                {error && (
                  <div style={{
                    backgroundColor: "var(--danger-bg)",
                    color: "#f87171",
                    padding: "8px 12px",
                    borderRadius: 6,
                    fontSize: 13
                  }}>
                    {error}
                  </div>
                )}

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                  <div className="form-group">
                    <label>New Base Salary (₹ INR)</label>
                    <input
                      type="number"
                      className="form-input"
                      value={newSalary}
                      onChange={(e) => setNewSalary(e.target.value)}
                      min="100000"
                      step="10000"
                      required
                    />
                  </div>

                  <div className="form-group">
                    <label>Reason for Revision</label>
                    <select
                      className="form-input"
                      value={reason}
                      onChange={(e) => setReason(e.target.value)}
                    >
                      {REASONS.map((r) => (
                        <option key={r} value={r}>{r}</option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="form-group">
                  <label>Audit Notes (Optional)</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="e.g., Performance rating review cycle / Executive signoff"
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                  />
                </div>

                {/* Adjustment Impact Preview */}
                <div style={{
                  backgroundColor: "rgba(59, 130, 246, 0.08)",
                  padding: "10px 14px",
                  borderRadius: 6,
                  display: "flex",
                  justifyContent: "space-between",
                  fontSize: 13
                }}>
                  <span>Adjustment: <strong>{hikePct > 0 ? `+${hikePct}%` : `${hikePct}%`}</strong></span>
                  <span>New Compa-Ratio: <strong>{newCompaRatio}%</strong></span>
                  <span>Formatted: <strong>{formatINR(targetSalary)}</strong></span>
                </div>

                <div style={{ display: "flex", justifyContent: "flex-end" }}>
                  <button type="submit" className="btn btn-primary" disabled={submitting}>
                    {submitting ? "Saving Revision..." : "Save Salary Adjustment"}
                  </button>
                </div>
              </form>

              {/* Historical Salary Adjustments Audit Trail */}
              <div>
                <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8, fontWeight: 700, fontSize: 14 }}>
                  <Clock size={16} color="#94a3b8" />
                  <span>Salary Adjustment History & Audit Trail</span>
                </div>

                {employee.salary_histories && employee.salary_histories.length > 0 ? (
                  <div className="timeline">
                    {employee.salary_histories.map((hist) => (
                      <div key={hist.id} className="timeline-item">
                        <div className="timeline-date">{formatDate(hist.effective_date)}</div>
                        <div className="timeline-content">
                          <strong>{hist.change_reason}</strong>: {formatINR(hist.previous_salary)} →{" "}
                          <span style={{ color: "#34d399", fontWeight: 700 }}>{formatINR(hist.new_salary)}</span>{" "}
                          ({hist.change_percentage > 0 ? `+${hist.change_percentage}%` : `${hist.change_percentage}%`})
                        </div>
                        {hist.notes && (
                          <div style={{ fontSize: 12, color: "var(--text-muted)", marginTop: 2 }}>
                            {hist.notes}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                ) : (
                  <p style={{ fontSize: 13, color: "var(--text-muted)", fontStyle: "italic" }}>
                    No previous revisions recorded. Current salary is the initial hiring compensation.
                  </p>
                )}
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
