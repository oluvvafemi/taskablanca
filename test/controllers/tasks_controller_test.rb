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
      password: "password"
    )
    OrganizationMembership.create!(user: new_user, organization: new_org, role: :member)
    sign_in_as(new_user, organization: new_org)

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

  test "should get new" do
    get new_task_url
    assert_response :success
    assert_match "Create New Task", @response.body
  end

  test "new form should have all required fields" do
    get new_task_url
    assert_response :success
    assert_match "title", @response.body
    assert_match "description", @response.body
    assert_match "project", @response.body
    assert_match "status", @response.body
  end

  test "new form should pre-select project from params" do
    get new_task_url, params: { project_id: projects(:website_redesign).id }
    assert_response :success
  end

  test "new form should list user's projects" do
    get new_task_url
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
    assert_match projects(:mobile_app).title, @response.body
  end

  test "should create task" do
    assert_difference("Task.count", 1) do
      assert_difference("TaskAssignment.count", 1) do
        post tasks_url, params: {
          task: {
            title: "New Test Task",
            description: "A test task description",
            status: "todo",
            project_id: projects(:website_redesign).id
          }
        }
      end
    end
    assert_redirected_to task_path(Task.last)
  end

  test "creator should be automatically assigned to task" do
    post tasks_url, params: {
      task: {
        title: "Assignment Test Task",
        description: "Testing auto-assignment",
        status: "todo",
        project_id: projects(:website_redesign).id
      }
    }
    new_task = Task.last
    assert_includes new_task.users, @user
  end

  test "should create task with different statuses" do
    %w[todo in_progress done].each do |status|
      assert_difference("Task.count", 1) do
        post tasks_url, params: {
          task: {
            title: "Task with #{status}",
            description: "Testing #{status} status",
            status: status,
            project_id: projects(:website_redesign).id
          }
        }
      end
      assert_equal status, Task.last.status
    end
  end

  test "should not create task without title" do
    assert_no_difference("Task.count") do
      post tasks_url, params: {
        task: {
          title: "",
          description: "Description only",
          project_id: projects(:website_redesign).id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create task without description" do
    assert_no_difference("Task.count") do
      post tasks_url, params: {
        task: {
          title: "Title only",
          description: "",
          project_id: projects(:website_redesign).id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create task for project user doesn't have access to" do
    bob_project = projects(:research_project)

    assert_no_difference("Task.count") do
      post tasks_url, params: {
        task: {
          title: "Unauthorized Task",
          description: "Should not be created",
          project_id: bob_project.id
        }
      }
    end
    assert_redirected_to tasks_path
  end

  test "should show task" do
    get task_url(tasks(:design_mockups))
    assert_response :success
    assert_match tasks(:design_mockups).title, @response.body
    assert_match tasks(:design_mockups).description, @response.body
  end

  test "show should display task project" do
    get task_url(tasks(:design_mockups))
    assert_response :success
    assert_match projects(:website_redesign).title, @response.body
  end

  test "show should display task status" do
    get task_url(tasks(:design_mockups))
    assert_response :success
    assert_match "Todo", @response.body
  end

  test "show should display assigned users" do
    get task_url(tasks(:design_mockups))
    assert_response :success
    assert_match @user.name, @response.body
  end

  test "should not show task user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    get task_url(tasks(:design_mockups))
    assert_redirected_to tasks_path
  end

  test "should get edit" do
    get edit_task_url(tasks(:design_mockups))
    assert_response :success
    assert_match "Edit Task", @response.body
    assert_match tasks(:design_mockups).title, @response.body
  end

  test "edit form should show current status" do
    task = tasks(:design_mockups)
    get edit_task_url(task)
    assert_response :success
    assert_match task.status, @response.body
  end

  test "should not get edit for task user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    get edit_task_url(tasks(:design_mockups))
    assert_redirected_to tasks_path
  end

  test "should update task" do
    patch task_url(tasks(:design_mockups)), params: {
      task: {
        title: "Updated Task Title",
        description: "Updated description",
        status: "in_progress"
      }
    }
    assert_redirected_to task_path(tasks(:design_mockups))

    tasks(:design_mockups).reload
    assert_equal "Updated Task Title", tasks(:design_mockups).title
    assert_equal "Updated description", tasks(:design_mockups).description
    assert_equal "in_progress", tasks(:design_mockups).status
  end

  test "should update task status" do
    task = tasks(:design_mockups)
    original_status = task.status

    patch task_url(task), params: {
      task: {
        status: "done"
      }
    }

    task.reload
    assert_not_equal original_status, task.status
    assert_equal "done", task.status
  end

  test "should not update task without title" do
    original_title = tasks(:design_mockups).title

    patch task_url(tasks(:design_mockups)), params: {
      task: {
        title: "",
        description: "Updated description"
      }
    }
    assert_response :unprocessable_entity

    tasks(:design_mockups).reload
    assert_equal original_title, tasks(:design_mockups).title
  end

  test "should not update task without description" do
    original_description = tasks(:design_mockups).description

    patch task_url(tasks(:design_mockups)), params: {
      task: {
        title: "Updated title",
        description: ""
      }
    }
    assert_response :unprocessable_entity

    tasks(:design_mockups).reload
    assert_equal original_description, tasks(:design_mockups).description
  end

  test "should not update task user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    patch task_url(tasks(:design_mockups)), params: {
      task: {
        title: "Hacked Title"
      }
    }
    assert_redirected_to tasks_path
  end

  test "should destroy task" do
    task = tasks(:setup_backend)
    project = task.project

    assert_difference("Task.count", -1) do
      delete task_url(task)
    end
    assert_redirected_to tasks_path
  end

  test "should not destroy task user doesn't have access to" do
    bob = users(:bob)
    sign_in_as(bob)

    assert_no_difference("Task.count") do
      delete task_url(tasks(:design_mockups))
    end
    assert_redirected_to tasks_path
  end

  test "destroying task should redirect to its project" do
    task = tasks(:design_mockups)
    project = task.project

    delete task_url(task)
    assert_redirected_to tasks_path
  end
end
