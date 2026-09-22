class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ArgumentError, with: :bad_argument

  private

  def record_not_found(exception)
    render json: { error: "Resource not found", details: exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { error: "Validation failed", errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def bad_argument(exception)
    render json: { error: "Invalid argument", details: exception.message }, status: :bad_request
  end
end
