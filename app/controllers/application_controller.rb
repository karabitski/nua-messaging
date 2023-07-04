class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by finder => true
  end

  private

  def finder
    case params[:type]
    when 'doctor' then 'is_doctor'
    when 'admin'  then 'is_admin'
    else
      'is_patient'
    end
  end
end
