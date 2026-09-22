import React, { useState, useEffect, useCallback } from "react";
import Header from "./components/Header";
import StatCards from "./components/StatCards";
import AnalyticsCharts from "./components/AnalyticsCharts";
import GenderPayGapChart from "./components/GenderPayGapChart";
import OutliersSection from "./components/OutliersSection";
import FilterBar from "./components/FilterBar";
import EmployeeTable from "./components/EmployeeTable";
import EmployeeModal from "./components/EmployeeModal";
import { api } from "./services/api";
import { BarChart3, Users, RefreshCw } from "lucide-react";

export default function App() {
  const [activeTab, setActiveTab] = useState("analytics"); // "analytics" or "directory"

  // Analytics data
  const [summary, setSummary] = useState(null);
  const [departments, setDepartments] = useState([]);
  const [locations, setLocations] = useState([]);
  const [payEquity, setPayEquity] = useState(null);
  const [distribution, setDistribution] = useState([]);
  const [outliers, setOutliers] = useState(null);
  const [analyticsLoading, setAnalyticsLoading] = useState(true);

  // Reference data
  const [referenceData, setReferenceData] = useState(null);

  // Employees table state
  const [employees, setEmployees] = useState([]);
  const [meta, setMeta] = useState({ current_page: 1, total_pages: 1, total_count: 0, per_page: 25 });
  const [tableLoading, setTableLoading] = useState(false);

  // Filter & Search state
  const [filters, setFilters] = useState({
    search: "",
    department_id: "",
    location_id: "",
    job_level_id: "",
    performance_rating: "",
    compa_status: ""
  });
  const [sortBy, setSortBy] = useState("salary");
  const [sortOrder, setSortOrder] = useState("desc");

  // Selected Employee for Modal
  const [selectedEmployeeId, setSelectedEmployeeId] = useState(null);

  // Initial Load: Reference Data & Analytics
  const loadAnalytics = useCallback(async () => {
    setAnalyticsLoading(true);
    try {
      const [sum, depts, locs, equity, dist, out] = await Promise.all([
        api.getAnalyticsSummary(),
        api.getDepartmentBreakdown(),
        api.getLocationBreakdown(),
        api.getPayEquity(),
        api.getCompaDistribution(),
        api.getOutliers()
      ]);

      setSummary(sum);
      setDepartments(depts.departments || []);
      setLocations(locs.locations || []);
      setPayEquity(equity);
      setDistribution(dist.distribution || []);
      setOutliers(out);
    } catch (err) {
      console.error("Failed to load analytics:", err);
    } finally {
      setAnalyticsLoading(false);
    }
  }, []);

  useEffect(() => {
    api.getReferenceData()
      .then(setReferenceData)
      .catch((err) => console.error("Failed to load reference data:", err));

    loadAnalytics();
  }, [loadAnalytics]);

  // Load Employees on filter/sort/page changes
  const loadEmployees = useCallback(async () => {
    setTableLoading(true);
    try {
      const response = await api.getEmployees({
        ...filters,
        sort_by: sortBy,
        sort_order: sortOrder,
        page: meta.current_page,
        per_page: meta.per_page
      });

      setEmployees(response.employees);
      setMeta(response.meta);
    } catch (err) {
      console.error("Failed to fetch employees:", err);
    } finally {
      setTableLoading(false);
    }
  }, [filters, sortBy, sortOrder, meta.current_page, meta.per_page]);

  useEffect(() => {
    const timer = setTimeout(() => {
      loadEmployees();
    }, 250); // debounce search/filter typing

    return () => clearTimeout(timer);
  }, [loadEmployees]);

  // Filter Handlers
  const handleFilterChange = (key, value) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
    setMeta((prev) => ({ ...prev, current_page: 1 }));
  };

  const handleResetFilters = () => {
    setFilters({
      search: "",
      department_id: "",
      location_id: "",
      job_level_id: "",
      performance_rating: "",
      compa_status: ""
    });
    setSortBy("salary");
    setSortOrder("desc");
    setMeta((prev) => ({ ...prev, current_page: 1 }));
  };

  const handleSort = (col) => {
    if (sortBy === col) {
      setSortOrder((prev) => (prev === "asc" ? "desc" : "asc"));
    } else {
      setSortBy(col);
      setSortOrder("desc");
    }
    setMeta((prev) => ({ ...prev, current_page: 1 }));
  };

  const handlePageChange = (newPage) => {
    setMeta((prev) => ({ ...prev, current_page: newPage }));
  };

  const handlePerPageChange = (newPerPage) => {
    setMeta((prev) => ({ ...prev, per_page: newPerPage, current_page: 1 }));
  };

  const handleSalaryUpdated = () => {
    loadEmployees();
    loadAnalytics();
  };

  return (
    <div className="app-container">
      <Header totalHeadcount={summary?.total_headcount || 10000} />

      <main className="main-content">
        {/* Navigation Tabs */}
        <div className="view-nav">
          <button
            className={`nav-tab ${activeTab === "analytics" ? "active" : ""}`}
            onClick={() => setActiveTab("analytics")}
          >
            <BarChart3 size={18} />
            <span>Executive Compensation Analytics ("How We Pay")</span>
          </button>
          <button
            className={`nav-tab ${activeTab === "directory" ? "active" : ""}`}
            onClick={() => setActiveTab("directory")}
          >
            <Users size={18} />
            <span>Employee Directory ({summary ? summary.total_headcount.toLocaleString("en-IN") : "10,000"} Records)</span>
          </button>
        </div>

        {/* Global KPI Cards (always visible for strategic alignment) */}
        <StatCards summary={summary} loading={analyticsLoading} />

        {/* Tab 1: Executive Analytics */}
        {activeTab === "analytics" && (
          <div>
            <AnalyticsCharts
              departments={departments}
              distribution={distribution}
              locations={locations}
            />

            <GenderPayGapChart payEquityData={payEquity} />

            <OutliersSection
              outliersData={outliers}
              onSelectEmployee={(id) => setSelectedEmployeeId(id)}
            />
          </div>
        )}

        {/* Tab 2: Employee Directory */}
        {activeTab === "directory" && (
          <div>
            <FilterBar
              filters={filters}
              onFilterChange={handleFilterChange}
              onResetFilters={handleResetFilters}
              referenceData={referenceData}
            />

            <EmployeeTable
              employees={employees}
              meta={meta}
              loading={tableLoading}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={handleSort}
              onPageChange={handlePageChange}
              onPerPageChange={handlePerPageChange}
              onSelectEmployee={(id) => setSelectedEmployeeId(id)}
            />
          </div>
        )}
      </main>

      {/* Salary Adjustment & Detail Modal */}
      {selectedEmployeeId && (
        <EmployeeModal
          employeeId={selectedEmployeeId}
          onClose={() => setSelectedEmployeeId(null)}
          onSalaryUpdated={handleSalaryUpdated}
        />
      )}
    </div>
  );
}
