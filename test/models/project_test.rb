require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    project = projects(:website_redesign)
    assert project.valid?
  end

  test "should require title" do
    project = Project.new(description: "Test description", organization: organizations(:acme))
    assert_not project.valid?
    assert_includes project.errors[:title], "can't be blank"
  end

  test "should require unique title scoped to organization" do
    existing_project = projects(:website_redesign)
    project = Project.new(
      title: existing_project.title,
      description: "Different description",
      organization: existing_project.organization
    )
    assert_not project.valid?
    assert_includes project.errors[:title], "has already been taken"
  end

  test "should allow same title for different organizations" do
    project = Project.new(
      title: projects(:website_redesign).title,
      description: "Same title, different org",
      organization: organizations(:stark)
    )
    assert project.valid?
  end

  test "should belong to organization" do
    project = projects(:website_redesign)
    assert_instance_of Organization, project.organization
    assert_equal organizations(:acme), project.organization
  end

  test "destroys associated tasks when project is destroyed" do
    org = Organization.create!(name: "Temp Org for Project Tasks")
    project = Project.create!(title: "Temp Project", description: "Desc", organization: org)
    project.tasks.create!(title: "Task One", description: "Desc")

    assert_difference "Task.count", -1 do
      project.destroy
    end
  end

  test "destroys associated project_memberships when project is destroyed" do
    org = Organization.create!(name: "Temp Org for Project Memberships")
    project = Project.create!(title: "Temp Project 2", description: "Desc", organization: org)
    user = User.create!(name: "Temp User", email_address: "temp_proj_mem@example.com", password: "password")
    project.project_memberships.create!(user: user)

    assert_difference "ProjectMembership.count", -1 do
      project.destroy
    end
  end

  test "destroying project does not destroy users" do
    project = projects(:website_redesign)
    user = users(:bob)
    membership = project.project_memberships.create!(user: user)

    project.destroy

    assert User.exists?(user.id)
  end

  test "projects are isolated by organization" do
    acme = organizations(:acme)
    stark = organizations(:stark)

    acme_project = acme.projects.create!(title: "ACME Project", description: "Description")
    stark_project = stark.projects.create!(title: "Stark Project", description: "Description")

    assert_includes acme.projects, acme_project
    assert_not_includes stark.projects, acme_project

    assert_includes stark.projects, stark_project
    assert_not_includes acme.projects, stark_project
  end
end
