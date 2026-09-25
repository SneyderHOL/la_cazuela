class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # TODO: use a forbidden route
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to(dashboard_path)
  end

  protected

  # Override the Devise method to customize redirection
  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
