class OrganizationMembershipsController < ApplicationController
  before_action :set_organization, only: [ :new, :create ]
  before_action :set_membership, only: [ :destroy ]
  before_action :require_admin_or_owner, only: [ :new, :create, :destroy ]

  def new
    @membership = @organization.organization_memberships.build
  end

  def create
    email = membership_params[:email_address].strip.downcase
    user = User.find_by(email_address: email)

    unless user
      password = SecureRandom.alphanumeric(12)
      user = User.create!(
        name: membership_params[:name].presence || email.split("@").first.titleize,
        email_address: email,
        password: password,
        password_confirmation: password
      )

      PasswordsMailer.reset(user).deliver_later
    end

    existing_membership = @organization.organization_memberships.find_by(user: user)
    if existing_membership
      redirect_to @organization, alert: "#{user.name} is already a member of this organization."
      return
    end

    role = membership_params[:role].presence || "member"
    membership = @organization.organization_memberships.create!(
      user: user,
      role: role
    )

    redirect_to @organization, notice: "#{user.name} has been added to the organization."
  end

  def destroy
    if @membership.owner? && @organization.organization_memberships.where(role: :owner).count == 1
      redirect_to @organization, alert: "Cannot remove the last owner. Assign another owner first."
      return
    end

    if @membership.user == Current.user
      redirect_to @organization, alert: "You cannot remove yourself. Have another admin remove you."
      return
    end

    user_name = @membership.user.name
    @membership.destroy
    redirect_to @organization, notice: "#{user_name} has been removed from the organization."
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path, alert: "Organization not found or you don't have access."
  end

  def set_membership
    @membership = OrganizationMembership.find(params[:id])
    @organization = @membership.organization

    unless Current.user.organizations.include?(@organization)
      redirect_to organizations_path, alert: "You don't have access to this organization."
    end
  end

  def require_admin_or_owner
    membership = Current.user.organization_memberships.find_by(organization: @organization)

    unless membership&.owner? || membership&.admin?
      redirect_to @organization, alert: "Only owners and admins can manage members."
    end
  end

  def membership_params
    params.require(:organization_membership).permit(:email_address, :name, :role)
  end
end
