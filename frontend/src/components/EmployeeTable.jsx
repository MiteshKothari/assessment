import React from "react";
import { formatINR, formatPercent, formatDate } from "../utils/formatters";
import { ArrowUpDown, ChevronLeft, ChevronRight, Edit3, Star } from "lucide-react";

export default function EmployeeTable({
  employees = [],
  meta = {},
  loading = false,
  sortBy,
  sortOrder,
  onSort,
  onPageChange,
  onPerPageChange,
  onSelectEmployee
}) {
  const { current_page = 1, total_pages = 1, total_count = 0, per_page = 25 } = meta;

  const renderSortIndicator = (col) => {
    if (sortBy !== col) return <ArrowUpDown size={12} style={{ opacity: 0.3, marginLeft: 4 }} />;
    return <span style={{ marginLeft: 4, color: "#3b82f6" }}>{sortOrder === "asc" ? "▲" : "▼"}</span>;
  };

  const getCompaBadge = (ratio) => {
    if (ratio < 80) {
      return <span className="badge badge-underpaid">{ratio}% Underpaid</span>;
    }
    if (ratio > 120) {
      return <span className="badge badge-overpaid">{ratio}% Above Band</span>;
    }
    return <span className="badge badge-in-band">{ratio}% In-Band</span>;
  };

  return (
    <div className="table-card">
      <div className="table-wrapper">
        <table className="data-table">
          <thead>
            <tr>
              <th onClick={() => onSort("employee_code")}>
                Code {renderSortIndicator("employee_code")}
              </th>
              <th onClick={() => onSort("name")}>
                Employee {renderSortIndicator("name")}
              </th>
              <th onClick={() => onSort("job_title")}>
                Role & Department {renderSortIndicator("job_title")}
              </th>
              <th>Location</th>
              <th>Level</th>
              <th onClick={() => onSort("salary")}>
                Annual Salary (INR) {renderSortIndicator("salary")}
              </th>
              <th onClick={() => onSort("compa_ratio")}>
                Compa-Ratio {renderSortIndicator("compa_ratio")}
              </th>
              <th onClick={() => onSort("performance_rating")}>
                Rating {renderSortIndicator("performance_rating")}
              </th>
              <th style={{ textAlign: "center" }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="9" className="state-center">
                  <div className="spinner" />
                  <p>Loading employee compensation records...</p>
                </td>
              </tr>
            ) : employees.length === 0 ? (
              <tr>
                <td colSpan="9" className="state-center">
                  <p>No employees match the specified filters.</p>
                </td>
              </tr>
            ) : (
              employees.map((emp) => (
                <tr key={emp.id} onClick={() => onSelectEmployee(emp.id)} style={{ cursor: "pointer" }}>
                  <td className="emp-code">{emp.employee_code}</td>
                  <td>
                    <div style={{ fontWeight: 600 }}>{emp.name}</div>
                    <div style={{ fontSize: 12, color: "var(--text-muted)" }}>{emp.email}</div>
                  </td>
                  <td>
                    <div>{emp.job_title}</div>
                    <div style={{ fontSize: 12, color: "var(--text-secondary)" }}>{emp.department_name}</div>
                  </td>
                  <td>{emp.location_city}</td>
                  <td>
                    <span style={{
                      backgroundColor: "rgba(255, 255, 255, 0.06)",
                      padding: "2px 8px",
                      borderRadius: 4,
                      fontSize: 12,
                      fontWeight: 600
                    }}>
                      {emp.job_level_name.split(" - ")[0]}
                    </span>
                  </td>
                  <td className="salary-val">{formatINR(emp.salary)}</td>
                  <td>{getCompaBadge(emp.compa_ratio)}</td>
                  <td>
                    <span className="rating-stars">
                      {"★".repeat(emp.performance_rating)}
                      <span style={{ opacity: 0.3 }}>{"★".repeat(5 - emp.performance_rating)}</span>
                    </span>
                  </td>
                  <td style={{ textAlign: "center" }} onClick={(e) => e.stopPropagation()}>
                    <button
                      className="btn btn-secondary"
                      style={{ padding: "5px 10px", fontSize: 12 }}
                      onClick={() => onSelectEmployee(emp.id)}
                      title="Adjust salary & view history"
                    >
                      <Edit3 size={13} />
                      <span>Adjust</span>
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination Controls */}
      <div className="pagination-bar">
        <div>
          Showing <strong>{employees.length > 0 ? (current_page - 1) * per_page + 1 : 0}</strong> to{" "}
          <strong>{Math.min(current_page * per_page, total_count)}</strong> of{" "}
          <strong>{total_count.toLocaleString("en-IN")}</strong> employees
        </div>

        <div className="pagination-controls">
          <label style={{ fontSize: 12, color: "var(--text-muted)" }}>Rows per page:</label>
          <select
            className="filter-select"
            style={{ padding: "4px 8px", fontSize: 12 }}
            value={per_page}
            onChange={(e) => onPerPageChange(Number(e.target.value))}
          >
            <option value={25}>25</option>
            <option value={50}>50</option>
            <option value={100}>100</option>
          </select>

          <button
            className="page-btn"
            disabled={current_page <= 1 || loading}
            onClick={() => onPageChange(current_page - 1)}
          >
            <ChevronLeft size={16} />
          </button>

          <span style={{ padding: "0 8px", fontWeight: 600 }}>
            Page {current_page} of {total_pages || 1}
          </span>

          <button
            className="page-btn"
            disabled={current_page >= total_pages || loading}
            onClick={() => onPageChange(current_page + 1)}
          >
            <ChevronRight size={16} />
          </button>
        </div>
      </div>
    </div>
  );
}
