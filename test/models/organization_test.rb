require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    org = organizations(:acme)
    assert org.valid?
  end

  test "requires name" do
    org = Organization.new
    assert_not org.valid?
    assert_includes org.errors[:name], "can't be blank"
  end

  test "requires unique name" do
    existing_org = organizations(:acme)
    org = Organization.new(name: existing_org.name)
    assert_not org.valid?
    assert_includes org.errors[:name], "has already been taken"
  end

  test "allows different organizations with different names" do
    org = Organization.new(name: "Unique Company Name")
    assert org.valid?
  end

  test "destroys associated organization_memberships when organization is destroyed" do
    org = Organization.create!(name: "Temp Org Users")
    user = User.create!(
      name: "Test User",
      email_address: "testuser@acme.com",
      password: "password"
    )
    OrganizationMembership.create!(user: user, organization: org, role: :member)

    assert_difference "OrganizationMembership.count", -1 do
      org.destroy
    end
  end

  test "destroys associated projects when organization is destroyed" do
    org = Organization.create!(name: "Temp Org Projects")
    project = org.projects.create!(title: "Test Project", description: "Description")

    assert_difference "Project.count", -1 do
      org.destroy
    end
  end

  test "destroys associated tasks through projects when organization is destroyed" do
    org = Organization.create!(name: "Temp Org Tasks")
    project = org.projects.create!(title: "Test Project", description: "Description")
    project.tasks.create!(title: "Test Task", description: "Task description")

    assert_difference "Task.count", -1 do
      org.destroy
    end
  end

  test "destroying organization does not affect other organizations" do
    org = organizations(:acme)
    other_org = organizations(:stark)

    other_user = other_org.users.create!(
      name: "Other User",
      email_address: "other@stark.com",
      password: "password"
    )
    other_project = other_org.projects.create!(
      title: "Other Project",
      description: "Description"
    )

    org.destroy

    assert User.exists?(other_user.id)
    assert Project.exists?(other_project.id)
  end
end
