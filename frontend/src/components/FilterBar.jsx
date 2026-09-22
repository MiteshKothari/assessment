import React from "react";
import { Search, Download, RotateCcw } from "lucide-react";
import { api } from "../services/api";

export default function FilterBar({
  filters,
  onFilterChange,
  onResetFilters,
  referenceData
}) {
  const { departments = [], locations = [], job_levels = [] } = referenceData || {};

  const handleExport = () => {
    const exportUrl = api.getExportUrl(filters);
    window.open(exportUrl, "_blank");
  };

  return (
    <div className="filter-bar">
      {/* Search Input */}
      <div className="search-input-wrap">
        <Search size={16} />
        <input
          type="text"
          className="search-input"
          placeholder="Search 10,000 employees by name, code, email, title..."
          value={filters.search || ""}
          onChange={(e) => onFilterChange("search", e.target.value)}
        />
      </div>

      {/* Department Filter */}
      <select
        className="filter-select"
        value={filters.department_id || ""}
        onChange={(e) => onFilterChange("department_id", e.target.value)}
      >
        <option value="">All Departments</option>
        {departments.map((d) => (
          <option key={d.id} value={d.id}>
            {d.name}
          </option>
        ))}
      </select>

      {/* Location Filter */}
      <select
        className="filter-select"
        value={filters.location_id || ""}
        onChange={(e) => onFilterChange("location_id", e.target.value)}
      >
        <option value="">All Locations</option>
        {locations.map((l) => (
          <option key={l.id} value={l.id}>
            {l.city} ({l.country})
          </option>
        ))}
      </select>

      {/* Job Level Filter */}
      <select
        className="filter-select"
        value={filters.job_level_id || ""}
        onChange={(e) => onFilterChange("job_level_id", e.target.value)}
      >
        <option value="">All Job Levels</option>
        {job_levels.map((lvl) => (
          <option key={lvl.id} value={lvl.id}>
            {lvl.name}
          </option>
        ))}
      </select>

      {/* Compa Status Filter */}
      <select
        className="filter-select"
        value={filters.compa_status || ""}
        onChange={(e) => onFilterChange("compa_status", e.target.value)}
      >
        <option value="">All Compa Bands</option>
        <option value="underpaid">Underpaid (&lt; 80%)</option>
        <option value="in_band">In-Band (80% - 120%)</option>
        <option value="overpaid">Above Band (&gt; 120%)</option>
      </select>

      {/* Performance Filter */}
      <select
        className="filter-select"
        value={filters.performance_rating || ""}
        onChange={(e) => onFilterChange("performance_rating", e.target.value)}
      >
        <option value="">All Ratings</option>
        <option value="5">Rating 5 (Exceptional)</option>
        <option value="4">Rating 4 (Exceeds)</option>
        <option value="3">Rating 3 (Meets)</option>
        <option value="2">Rating 2 (Developing)</option>
        <option value="1">Rating 1 (Needs Improvement)</option>
      </select>

      {/* Clear Filters */}
      <button className="btn btn-secondary" onClick={onResetFilters} title="Reset all filters">
        <RotateCcw size={15} />
        <span>Reset</span>
      </button>

      {/* Export to CSV */}
      <button className="btn btn-export" onClick={handleExport} title="Export filtered set to CSV">
        <Download size={15} />
        <span>Export CSV</span>
      </button>
    </div>
  );
}
