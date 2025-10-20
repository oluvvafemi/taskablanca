class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_organization

  private

  def set_current_organization
    return unless authenticated?

    if session[:current_organization_id]
      membership = Current.user.organization_memberships.find_by(organization_id: session[:current_organization_id])
      Current.organization = membership.organization if membership
    end

    unless Current.organization
      Current.organization = Current.user.organizations.first
      session[:current_organization_id] = Current.organization&.id
    end
  end
end
