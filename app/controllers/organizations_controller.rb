class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def index
    @organizations = Current.user.organizations.includes(:organization_memberships)
  end

  def show
    @members = @organization.organization_memberships.includes(:user).order(role: :desc, created_at: :asc)
    @projects = @organization.projects.includes(:tasks)
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      OrganizationMembership.create!(user: Current.user, organization: @organization, role: :owner)

      session[:current_organization_id] = @organization.id

      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    other_members = @organization.organization_memberships.where.not(user: Current.user)

    if other_members.exists?
      redirect_to @organization, alert: "Cannot delete organization with other members. Remove them first or transfer ownership."
      return
    end

    @organization.destroy
    session.delete(:current_organization_id)
    redirect_to organizations_path, notice: "Organization was successfully deleted."
  end

  def switch
    membership = Current.user.organization_memberships.find_by(organization_id: params[:id])

    if membership
      session[:current_organization_id] = membership.organization_id
      redirect_to root_path, notice: "Switched to #{membership.organization.name}."
    else
      redirect_to organizations_path, alert: "You don't have access to that organization."
    end
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizations_path, alert: "Organization not found or you don't have access."
  end

  def require_owner
    membership = Current.user.organization_memberships.find_by(organization: @organization)

    unless membership&.owner?
      redirect_to @organization, alert: "Only organization owners can perform this action."
    end
  end

  def organization_params
    params.require(:organization).permit(:name)
  end
end
