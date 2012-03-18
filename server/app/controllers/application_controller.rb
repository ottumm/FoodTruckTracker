class ApplicationController < ActionController::Base
  protect_from_forgery

  def client_time_zone
    if params[:tz]
      cookies[:tz] = params[:tz]
      ActiveSupport::TimeZone[params[:tz].to_i]
    elsif cookies[:tz]
      ActiveSupport::TimeZone[cookies[:tz].to_i]
    else
      "Pacific Time (US & Canada)"
    end
  end
end
