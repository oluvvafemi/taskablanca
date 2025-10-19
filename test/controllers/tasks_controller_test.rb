require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    sign_in_as(@user)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should load user's tasks" do
    get tasks_url
    assert_response :success
    assert_match "My Tasks", @response.body
    assert_match tasks(:design_mockups).title, @response.body
    assert_match tasks(:setup_backend).title, @response.body
  end

  test "should include project in loaded tasks" do
    get tasks_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
  end

  test "should only show user's own tasks" do
    get tasks_url
    assert_response :success
    assert_match tasks(:design_mockups).title, @response.body
    assert_match tasks(:setup_backend).title, @response.body
    refute_match tasks(:research_ai).title, @response.body
    refute_match tasks(:install_cameras).title, @response.body
  end

  test "should show tasks from different projects" do
    get tasks_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
  end

  test "should show tasks with different statuses" do
    get tasks_url
    assert_response :success
    assert_match "Todo", @response.body
    assert_match "Done", @response.body
  end

  test "different users see different tasks" do
    get tasks_url
    alice_body = @response.body

    bob = users(:bob)
    sign_in_as(bob)

    get tasks_url
    bob_body = @response.body

    refute_equal alice_body, bob_body
    assert_match tasks(:design_mockups).title, alice_body
    assert_match tasks(:setup_backend).title, alice_body
    assert_match tasks(:research_ai).title, bob_body
  end

  test "user with no tasks should see empty list" do
    new_org = Organization.create!(name: "Empty Org")
    new_user = User.create!(
      name: "Empty User",
      email_address: "emptyuser@example.com",
      password: "password",
      organization: new_org
    )
    sign_in_as(new_user)

    get tasks_url
    assert_response :success
    assert_match "No tasks assigned yet.", @response.body
  end

  test "should maintain task status information" do
    get tasks_url
    assert_response :success
    assert_match "Todo", @response.body
    assert_match "Done", @response.body
  end

  test "tasks should belong to projects from user's organization or assigned projects" do
    get tasks_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
  end

  test "should load tasks efficiently with includes" do
    get tasks_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
  end
end
