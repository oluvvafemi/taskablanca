require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = users(:alice)
    assert user.valid?
  end

  test "should require name" do
    user = User.new(email_address: "test@example.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email_address" do
    user = User.new(name: "Test User", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should require unique email_address" do
    existing_user = users(:alice)
    user = User.new(name: "Another User", email_address: existing_user.email_address, password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "should normalize email_address by downcasing" do
    user = User.create!(name: "Test User", email_address: "TEST@EXAMPLE.COM", password: "password")
    assert_equal "test@example.com", user.email_address
  end

  test "should normalize email_address by stripping whitespace" do
    user = User.create!(name: "Test User", email_address: "  test@example.com  ", password: "password")
    assert_equal "test@example.com", user.email_address
  end

  test "should require password on creation" do
    user = User.new(name: "Test User", email_address: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should have organizations through memberships" do
    user = users(:alice)
    assert user.organizations.any?
    assert_includes user.organizations, organizations(:acme)
  end

  test "destroys associated sessions when user is destroyed" do
    user = User.create!(name: "Temp User", email_address: "temp_sessions@example.com", password: "password")
    user.sessions.create!(user_agent: "Test Agent", ip_address: "127.0.0.1")

    assert_difference "Session.count", -1 do
      user.destroy
    end
  end

  test "destroys associated project_memberships when user is destroyed" do
    org = Organization.create!(name: "Temp Org for Memberships")
    project = Project.create!(title: "Temp Project", description: "Desc", organization: org)
    user = User.create!(name: "Temp User", email_address: "temp_members@example.com", password: "password")
    user.project_memberships.create!(project: project)

    assert_difference "ProjectMembership.count", -1 do
      user.destroy
    end
  end

  test "destroys associated task_assignments when user is destroyed" do
    org = Organization.create!(name: "Temp Org for Assignments")
    project = Project.create!(title: "Temp Project A", description: "Desc", organization: org)
    task = Task.create!(title: "Temp Task", description: "Desc", project: project)
    user = User.create!(name: "Temp User", email_address: "temp_assign@example.com", password: "password")
    user.task_assignments.create!(task: task)

    assert_difference "TaskAssignment.count", -1 do
      user.destroy
    end
  end

  test "should authenticate with correct password" do
    user = User.authenticate_by(email_address: "alice@acme.com", password: "password")
    assert_not_nil user
    assert_equal users(:alice), user
  end

  test "should not authenticate with incorrect password" do
    user = User.authenticate_by(email_address: "alice@acme.com", password: "wrongpassword")
    assert_nil user
  end

  test "should not authenticate with non-existent email" do
    user = User.authenticate_by(email_address: "nonexistent@example.com", password: "password")
    assert_nil user
  end
end
