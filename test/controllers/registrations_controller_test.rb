require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new registration form" do
    get new_registration_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference "User.count", 1 do
      post registration_url, params: {
        user: {
          name: "New User",
          email_address: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    
    assert_redirected_to root_path
  end

  test "should create default organization on registration" do
    assert_difference "Organization.count", 1 do
      post registration_url, params: {
        user: {
          name: "Test User",
          email_address: "testorg@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    
    new_user = User.find_by(email_address: "testorg@example.com")
    assert_equal "Test User's Organization", new_user.organizations.first.name
  end

  test "should create owner membership on registration" do
    assert_difference "OrganizationMembership.count", 1 do
      post registration_url, params: {
        user: {
          name: "Owner Test",
          email_address: "owner@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    
    new_user = User.find_by(email_address: "owner@example.com")
    membership = new_user.organization_memberships.first
    assert membership.owner?
  end

  test "should log user in after registration" do
    post registration_url, params: {
      user: {
        name: "Login Test",
        email_address: "login@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
    
    new_user = User.find_by(email_address: "login@example.com")
    assert new_user.sessions.any?, "User should have a session after registration"
  end

  test "should set current organization in session" do
    post registration_url, params: {
      user: {
        name: "Session Test",
        email_address: "session@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
    
    new_user = User.find_by(email_address: "session@example.com")
    assert_equal new_user.organizations.first.id, session[:current_organization_id]
  end

  test "should not create user with invalid params" do
    assert_no_difference "User.count" do
      post registration_url, params: {
        user: {
          name: "",
          email_address: "invalid",
          password: "short"
        }
      }
    end
    
    assert_response :unprocessable_entity
  end

  test "should require name" do
    post registration_url, params: {
      user: {
        name: "",
        email_address: "test@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
    
    assert_response :unprocessable_entity
  end

  test "should require email address" do
    post registration_url, params: {
      user: {
        name: "Test",
        email_address: "",
        password: "password",
        password_confirmation: "password"
      }
    }
    
    assert_response :unprocessable_entity
  end

  test "should require unique email address" do
    post registration_url, params: {
      user: {
        name: "Duplicate",
        email_address: users(:alice).email_address,
        password: "password",
        password_confirmation: "password"
      }
    }
    
    assert_response :unprocessable_entity
  end

  test "should require password" do
    post registration_url, params: {
      user: {
        name: "Test",
        email_address: "test@example.com",
        password: "",
        password_confirmation: ""
      }
    }
    
    assert_response :unprocessable_entity
  end
end

