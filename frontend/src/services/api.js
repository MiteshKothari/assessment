// API Client for ACME Salary Platform
const BASE_URL = "/api/v1";

async function request(endpoint, options = {}) {
  const url = `${BASE_URL}${endpoint}`;
  const response = await fetch(url, {
    headers: {
      "Content-Type": "application/json",
      ...options.headers
    },
    ...options
  });

  if (!response.ok) {
    let errorMsg = `HTTP Error ${response.status}`;
    try {
      const errorData = await response.json();
      errorMsg = errorData.error || errorData.details || errorMsg;
    } catch {
      // ignore
    }
    throw new Error(errorMsg);
  }

  return response.json();
}

export const api = {
  // Reference data (departments, locations, job_levels)
  getReferenceData: () => request("/reference_data"),

  // Analytics endpoints
  getAnalyticsSummary: () => request("/analytics/summary"),
  getDepartmentBreakdown: () => request("/analytics/department_breakdown"),
  getLocationBreakdown: () => request("/analytics/location_breakdown"),
  getPayEquity: () => request("/analytics/pay_equity"),
  getCompaDistribution: () => request("/analytics/compa_distribution"),
  getOutliers: () => request("/analytics/outliers"),

  // Employee endpoints
  getEmployees: (params = {}) => {
    const query = new URLSearchParams();
    Object.entries(params).forEach(([key, val]) => {
      if (val !== undefined && val !== null && val !== "") {
        query.append(key, val);
      }
    });
    return request(`/employees?${query.toString()}`);
  },

  getEmployee: (id) => request(`/employees/${id}`),

  adjustSalary: (id, payload) =>
    request(`/employees/${id}/adjust_salary`, {
      method: "POST",
      body: JSON.stringify(payload)
    }),

  getExportUrl: (params = {}) => {
    const query = new URLSearchParams();
    Object.entries(params).forEach(([key, val]) => {
      if (val !== undefined && val !== null && val !== "") {
        query.append(key, val);
      }
    });
    return `${BASE_URL}/employees/export?${query.toString()}`;
  }
};
