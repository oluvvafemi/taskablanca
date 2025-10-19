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

  test "should get new" do
    get new_project_url
    assert_response :success
    assert_match "Create New Project", @response.body
  end

  test "new form should have all required fields" do
    get new_project_url
    assert_response :success
    assert_match "title", @response.body
    assert_match "description", @response.body
  end

  test "should create project" do
    assert_difference("Project.count", 1) do
      assert_difference("ProjectMembership.count", 1) do
        post projects_url, params: {
          project: {
            title: "New Test Project",
            description: "A test project description"
          }
        }
      end
    end
    assert_redirected_to project_path(Project.last)
  end

  test "created project should belong to user's organization" do
    post projects_url, params: {
      project: {
        title: "Org Test Project",
        description: "Testing organization assignment"
      }
    }
    new_project = Project.last
    assert_equal @user.organization, new_project.organization
  end

  test "creator should be automatically added as project member" do
    post projects_url, params: {
      project: {
        title: "Membership Test Project",
        description: "Testing auto-membership"
      }
    }
    new_project = Project.last
    assert_includes new_project.users, @user
  end

  test "should not create project without title" do
    assert_no_difference("Project.count") do
      post projects_url, params: {
        project: {
          title: "",
          description: "Description only"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create project with duplicate title in same organization" do
    post projects_url, params: {
      project: {
        title: projects(:website_redesign).title,
        description: "Duplicate title"
      }
    }
    assert_response :unprocessable_entity
  end

  test "should show project" do
    get project_url(projects(:website_redesign))
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:website_redesign).description, @response.body
  end

  test "show should display project tasks" do
    get project_url(projects(:website_redesign))
    assert_response :success
    assert_match tasks(:design_mockups).title, @response.body
    assert_match tasks(:implement_navbar).title, @response.body
  end

  test "should not show project user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    get project_url(projects(:website_redesign))
    assert_redirected_to projects_path
  end

  test "should get edit" do
    get edit_project_url(projects(:website_redesign))
    assert_response :success
    assert_match "Edit Project", @response.body
    assert_match projects(:website_redesign).title, @response.body
  end

  test "should not get edit for project user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    get edit_project_url(projects(:website_redesign))
    assert_redirected_to projects_path
  end

  test "should update project" do
    patch project_url(projects(:website_redesign)), params: {
      project: {
        title: "Updated Project Title",
        description: "Updated description"
      }
    }
    assert_redirected_to project_path(projects(:website_redesign))

    projects(:website_redesign).reload
    assert_equal "Updated Project Title", projects(:website_redesign).title
    assert_equal "Updated description", projects(:website_redesign).description
  end

  test "should not update project without title" do
    original_title = projects(:website_redesign).title

    patch project_url(projects(:website_redesign)), params: {
      project: {
        title: "",
        description: "Updated description"
      }
    }
    assert_response :unprocessable_entity

    projects(:website_redesign).reload
    assert_equal original_title, projects(:website_redesign).title
  end

  test "should not update project user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    patch project_url(projects(:website_redesign)), params: {
      project: {
        title: "Hacked Title"
      }
    }
    assert_redirected_to projects_path
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(projects(:mobile_app))
    end
    assert_redirected_to projects_url
  end

  test "destroying project should destroy associated tasks" do
    project = projects(:website_redesign)
    task_ids = project.tasks.pluck(:id)

    assert task_ids.any?, "Project should have tasks"

    delete project_url(project)

    task_ids.each do |task_id|
      assert_nil Task.find_by(id: task_id), "Task #{task_id} should be deleted"
    end
  end

  test "should not destroy project user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    assert_no_difference("Project.count") do
      delete project_url(projects(:website_redesign))
    end
    assert_redirected_to projects_path
  end
end
