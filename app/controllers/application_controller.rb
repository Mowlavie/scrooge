class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    
    private
    
    def current_user
      @current_user ||= User.find_by(id: request.headers['User-ID'])
    end
    
    def require_user
      render json: { error: 'User ID required in headers' }, status: :unauthorized unless current_user
    end
    
    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end
    
    def unprocessable_entity(exception)
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
  end