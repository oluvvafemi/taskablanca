class ProfilesController < ApplicationController
  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = Current.user

    sole_owner_orgs_with_members = @user.organization_memberships.where(role: :owner).select do |membership|
      org = membership.organization
      other_members = org.organization_memberships.where.not(user: @user)
      owners_count = org.organization_memberships.where(role: :owner).count

      owners_count == 1 && other_members.exists?
    end

    if sole_owner_orgs_with_members.any?
      org_names = sole_owner_orgs_with_members.map { |m| m.organization.name }.join(", ")
      redirect_to profile_path, alert: "Cannot close account. You are the sole owner of: #{org_names}. Please transfer ownership or remove other members first."
      return
    end

    @user.organization_memberships.where(role: :owner).each do |membership|
      org = membership.organization
      if org.organization_memberships.count == 1
        org.destroy
      end
    end

    @user.sessions.destroy_all
    @user.destroy

    redirect_to new_session_path, notice: "Your account has been closed."
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email_address)
  end
end
