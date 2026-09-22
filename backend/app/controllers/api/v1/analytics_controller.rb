module Api
  module V1
    class AnalyticsController < ApplicationController
      # GET /api/v1/analytics/summary
      def summary
        render json: SalaryAnalyticsService.summary
      end

      # GET /api/v1/analytics/department_breakdown
      def department_breakdown
        render json: {
          departments: SalaryAnalyticsService.department_breakdown
        }
      end

      # GET /api/v1/analytics/location_breakdown
      def location_breakdown
        render json: {
          locations: SalaryAnalyticsService.location_breakdown
        }
      end

      # GET /api/v1/analytics/pay_equity
      def pay_equity
        render json: SalaryAnalyticsService.pay_equity
      end

      # GET /api/v1/analytics/compa_distribution
      def compa_distribution
        render json: {
          distribution: SalaryAnalyticsService.compa_distribution
        }
      end

      # GET /api/v1/analytics/outliers
      def outliers
        render json: SalaryAnalyticsService.outliers
      end
    end
  end
end
