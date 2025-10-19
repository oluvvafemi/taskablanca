require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    sign_in_as(@user)
  end

  test "should show dashboard" do
    get root_url
    assert_response :success
  end

  test "should load current user" do
    get root_url
    assert_response :success
    assert_match "My Tasks", @response.body
  end

  test "should load user's projects with tasks" do
    get root_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
  end

  test "should load user's tasks with projects" do
    get root_url
    assert_response :success
    assert_match tasks(:design_mockups).title, @response.body
    assert_match tasks(:setup_backend).title, @response.body
  end

  test "should calculate total projects count" do
    get root_url
    assert_response :success
    assert_match "Projects", @response.body
  end

  test "should calculate total tasks count" do
    get root_url
    assert_response :success
    assert_match "Total Tasks", @response.body
  end

  test "should calculate todo tasks count" do
    get root_url
    assert_response :success
    assert_match "Todo", @response.body
  end

  test "should calculate in_progress tasks count" do
    get root_url
    assert_response :success
    assert_match "In Progress", @response.body
  end

  test "should calculate done tasks count" do
    get root_url
    assert_response :success
    assert_match "Completed", @response.body
  end

  test "should only show user's own projects" do
    get root_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    refute_match projects(:research_project).title, @response.body
  end

  test "should only show user's own tasks" do
    get root_url
    assert_response :success
    assert_match tasks(:design_mockups).title, @response.body
    refute_match tasks(:research_ai).title, @response.body
  end

  test "different users see different dashboards" do
    get root_url
    alice_body = @response.body

    bob = users(:bob)
    sign_in_as(bob)

    get root_url
    bob_body = @response.body

    refute_equal alice_body, bob_body
    assert_match projects(:website_redesign).title, alice_body
    assert_match tasks(:research_ai).title, bob_body
  end
end
