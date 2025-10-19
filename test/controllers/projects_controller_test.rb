require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    sign_in_as(@user)
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should load user's projects" do
    get projects_url
    assert_response :success
    assert_match "Projects", @response.body
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
  end

  test "should include organization in loaded projects" do
    get projects_url
    assert_response :success
    assert_match projects(:website_redesign).organization.name, @response.body
  end

  test "should include tasks in loaded projects" do
    get projects_url
    assert_response :success
    assert_match "tasks", @response.body
  end

  test "should only show user's own projects" do
    get projects_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
    refute_match projects(:research_project).title, @response.body
    refute_match projects(:security_upgrade).title, @response.body
  end

  test "different users see different projects" do
    get projects_url
    alice_body = @response.body

    bob = users(:bob)
    sign_in_as(bob)

    get projects_url
    bob_body = @response.body

    refute_equal alice_body, bob_body
    assert_match projects(:website_redesign).title, alice_body
    assert_match projects(:research_project).title, bob_body
  end

  test "user with no projects should see empty list" do
    new_org = Organization.create!(name: "New Org")
    new_user = User.create!(
      name: "New User",
      email_address: "newuser@example.com",
      password: "password",
      organization: new_org
    )
    sign_in_as(new_user)

    get projects_url
    assert_response :success
    assert_match "No projects yet.", @response.body
  end

  test "should handle user with multiple projects from same organization" do
    get projects_url
    assert_response :success
    assert_match organizations(:acme).name, @response.body
  end
end
