require "test_helper"

class OrganizationMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @diana = users(:diana)
    @acme = organizations(:acme)
    @stark = organizations(:stark)
    sign_in_as(@alice, organization: @acme)
  end

  test "owner should be able to invite existing user" do
    assert_difference "OrganizationMembership.count", 1 do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: @diana.email_address,
          role: "member"
        }
      }
    end
    
    assert_redirected_to organization_path(@acme)
    assert @acme.users.include?(@diana)
  end

  test "admin should be able to invite existing user" do
    charlie_membership = @charlie.organization_memberships.find_by(organization: @acme)
    charlie_membership.update!(role: :admin)
    sign_in_as(@charlie, organization: @acme)
    
    assert_difference "OrganizationMembership.count", 1 do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: @diana.email_address,
          role: "member"
        }
      }
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "member should not be able to invite users" do
    sign_in_as(@charlie, organization: @acme)
    
    assert_no_difference "OrganizationMembership.count" do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: @diana.email_address,
          role: "member"
        }
      }
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "should assign role when inviting" do
    post organization_organization_memberships_url(@acme), params: {
      organization_membership: {
        email_address: @diana.email_address,
        role: "admin"
      }
    }
    
    membership = @acme.organization_memberships.find_by(user: @diana)
    assert membership.admin?
  end

  test "should not create duplicate membership" do
    assert_no_difference "OrganizationMembership.count" do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: @charlie.email_address,
          role: "member"
        }
      }
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "should create user if email does not exist" do
    assert_difference "User.count", 1 do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: "newuser@example.com",
          name: "New User",
          role: "member"
        }
      }
    end
    
    new_user = User.find_by(email_address: "newuser@example.com")
    assert_not_nil new_user
    assert @acme.users.include?(new_user)
  end

  test "should create membership for new user" do
    assert_difference "OrganizationMembership.count", 1 do
      post organization_organization_memberships_url(@acme), params: {
        organization_membership: {
          email_address: "another@example.com",
          role: "member"
        }
      }
    end
  end

  test "should use email prefix as name if name not provided" do
    post organization_organization_memberships_url(@acme), params: {
      organization_membership: {
        email_address: "testname@example.com",
        role: "member"
      }
    }
    
    new_user = User.find_by(email_address: "testname@example.com")
    assert_equal "Testname", new_user.name
  end

  test "owner should be able to remove member" do
    charlie_membership = @charlie.organization_memberships.find_by(organization: @acme)
    
    assert_difference "OrganizationMembership.count", -1 do
      delete organization_membership_url(charlie_membership)
    end
    
    assert_redirected_to organization_path(@acme)
    assert_not @acme.reload.users.include?(@charlie)
  end

  test "admin should be able to remove member" do
    charlie_membership = @charlie.organization_memberships.find_by(organization: @acme)
    charlie_membership.update!(role: :admin)
    
    OrganizationMembership.create!(user: @diana, organization: @acme, role: :member)
    diana_membership = @diana.organization_memberships.find_by(organization: @acme)
    
    sign_in_as(@charlie, organization: @acme)
    
    assert_difference "OrganizationMembership.count", -1 do
      delete organization_membership_url(diana_membership)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "member should not be able to remove other members" do
    OrganizationMembership.create!(user: @diana, organization: @acme, role: :member)
    diana_membership = @diana.organization_memberships.find_by(organization: @acme)
    
    sign_in_as(@charlie, organization: @acme)
    
    assert_no_difference "OrganizationMembership.count" do
      delete organization_membership_url(diana_membership)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "should not remove last owner" do
    alice_membership = @alice.organization_memberships.find_by(organization: @acme)
    
    assert_no_difference "OrganizationMembership.count" do
      delete organization_membership_url(alice_membership)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "should be able to remove owner if there are other owners" do
    charlie_membership = @charlie.organization_memberships.find_by(organization: @acme)
    charlie_membership.update!(role: :owner)
    
    sign_in_as(@charlie, organization: @acme)
    alice_membership = @alice.organization_memberships.find_by(organization: @acme)
    
    assert_difference "OrganizationMembership.count", -1 do
      delete organization_membership_url(alice_membership)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "should not be able to remove yourself" do
    alice_membership = @alice.organization_memberships.find_by(organization: @acme)
    
    assert_no_difference "OrganizationMembership.count" do
      delete organization_membership_url(alice_membership)
    end
    
    assert_redirected_to organization_path(@acme)
  end
end

