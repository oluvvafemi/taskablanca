require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
    @acme = organizations(:acme)
    @stark = organizations(:stark)
    sign_in_as(@alice, organization: @acme)
  end

  test "should get organizations index" do
    get organizations_url
    assert_response :success
  end

  test "should show organization user is member of" do
    get organization_url(@acme)
    assert_response :success
  end

  test "should not show organization user is not member of" do
    get organization_url(@stark)
    assert_redirected_to organizations_path
  end

  test "should create new organization" do
    assert_difference "Organization.count", 1 do
      post organizations_url, params: {
        organization: {
          name: "New Company"
        }
      }
    end
    
    new_org = Organization.last
    assert_redirected_to organization_path(new_org)
  end

  test "should make creator owner of new organization" do
    assert_difference "OrganizationMembership.count", 1 do
      post organizations_url, params: {
        organization: {
          name: "Creator Test Org"
        }
      }
    end
    
    new_org = Organization.last
    membership = @alice.organization_memberships.find_by(organization: new_org)
    assert membership.owner?
  end

  test "should switch to new organization on creation" do
    post organizations_url, params: {
      organization: {
        name: "Switch Test Org"
      }
    }
    
    new_org = Organization.last
    assert_equal new_org.id, session[:current_organization_id]
  end

  test "should not create organization with invalid name" do
    assert_no_difference "Organization.count" do
      post organizations_url, params: {
        organization: {
          name: ""
        }
      }
    end
    
    assert_response :unprocessable_entity
  end

  test "should switch to organization user is member of" do
    OrganizationMembership.create!(user: @alice, organization: @stark, role: :member)
    
    post switch_organization_url(@stark)
    assert_redirected_to root_path
    assert_equal @stark.id, session[:current_organization_id]
  end

  test "should not switch to organization user is not member of" do
    old_org_id = session[:current_organization_id]
    
    post switch_organization_url(@stark)
    assert_redirected_to organizations_path
    assert_equal old_org_id, session[:current_organization_id]
  end

  test "owner should be able to update organization" do
    patch organization_url(@acme), params: {
      organization: {
        name: "ACME Updated"
      }
    }
    
    assert_redirected_to organization_path(@acme)
    assert_equal "ACME Updated", @acme.reload.name
  end

  test "non-owner should not be able to update organization" do
    sign_in_as(@charlie, organization: @acme)
    
    patch organization_url(@acme), params: {
      organization: {
        name: "ACME Hacked"
      }
    }
    
    assert_redirected_to organization_path(@acme)
    assert_not_equal "ACME Hacked", @acme.reload.name
  end

  test "should get edit form if owner" do
    get edit_organization_url(@acme)
    assert_response :success
  end

  test "should not get edit form if not owner" do
    sign_in_as(@charlie, organization: @acme)
    
    get edit_organization_url(@acme)
    assert_redirected_to organization_path(@acme)
  end

  test "owner should be able to delete organization with no other members" do
    solo_org = Organization.create!(name: "Solo Org")
    OrganizationMembership.create!(user: @alice, organization: solo_org, role: :owner)
    
    assert_difference "Organization.count", -1 do
      delete organization_url(solo_org)
    end
    
    assert_redirected_to organizations_path
  end

  test "owner should not be able to delete organization with other members" do
    assert_no_difference "Organization.count" do
      delete organization_url(@acme)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "non-owner should not be able to delete organization" do
    sign_in_as(@charlie, organization: @acme)
    
    assert_no_difference "Organization.count" do
      delete organization_url(@acme)
    end
    
    assert_redirected_to organization_path(@acme)
  end

  test "deleting organization clears it from session if current" do
    solo_org = Organization.create!(name: "Session Test Org")
    OrganizationMembership.create!(user: @alice, organization: solo_org, role: :owner)
    post switch_organization_url(solo_org)
    
    assert_equal solo_org.id, session[:current_organization_id]
    
    delete organization_url(solo_org)
    assert_nil session[:current_organization_id]
  end
end

