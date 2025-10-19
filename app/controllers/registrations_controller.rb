class RegistrationsController < ApplicationController
  layout "auth"
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      organization = Organization.create!(name: "#{@user.name}'s Organization")

      OrganizationMembership.create!(user: @user, organization: organization, role: :owner)

      start_new_session_for(@user)
      session[:current_organization_id] = organization.id

      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
