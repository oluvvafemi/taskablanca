require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    sign_in_as @user
  end

  test "should get show" do
    get profile_url
    assert_response :success
    assert_select "input[name='user[name]']", 0
    assert_select "input[name='user[email_address]']", 0
  end

  test "should get edit" do
    get edit_profile_url
    assert_response :success
    assert_select "input[name='user[name]']", 1
    assert_select "input[name='user[email_address]']", 1
    assert_select "input[type='submit']", 1
  end

  test "should update profile" do
    patch profile_url, params: { user: { name: "Updated Name", email_address: "updated@example.com" } }
    assert_redirected_to profile_url
    assert_equal "Updated Name", @user.reload.name
    assert_equal "updated@example.com", @user.reload.email_address
  end

  test "should not update profile with invalid data" do
    patch profile_url, params: { user: { name: "", email_address: "invalid-email" } }
    assert_response :unprocessable_entity
  end
end
