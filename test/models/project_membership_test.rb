require "test_helper"

class ProjectMembershipTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    membership = project_memberships(:alice_website)
    assert membership.valid?
  end

  test "belongs to user" do
    membership = project_memberships(:alice_website)
    assert_instance_of User, membership.user
    assert_equal users(:alice), membership.user
  end

  test "belongs to project" do
    membership = project_memberships(:alice_website)
    assert_instance_of Project, membership.project
    assert_equal projects(:website_redesign), membership.project
  end

  test "user can access project after membership is created" do
    user = users(:diana)
    project = projects(:mobile_app)

    assert_not_includes user.projects, project

    ProjectMembership.create!(user: user, project: project)
    user.reload

    assert_includes user.projects, project
  end
end
