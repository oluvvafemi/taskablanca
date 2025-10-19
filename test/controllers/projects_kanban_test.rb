require "test_helper"

class ProjectsKanbanTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    @project = projects(:website_redesign)
    sign_in_as(@user)
  end

  test "should get kanban board" do
    get kanban_project_url(@project)
    assert_response :success
    assert_match "Kanban Board", @response.body
  end

  test "should display tasks in correct columns" do
    get kanban_project_url(@project)
    assert_response :success

    assert_match "To Do", @response.body
    assert_match "In Progress", @response.body
    assert_match "Done", @response.body

    @project.tasks.each do |task|
      case task.status
      when "todo"
        assert_select "#todo_tasks", text: /#{Regexp.escape(task.title)}/
      when "in_progress"
        assert_select "#in_progress_tasks", text: /#{Regexp.escape(task.title)}/
      when "done"
        assert_select "#done_tasks", text: /#{Regexp.escape(task.title)}/
      end
    end
  end

  test "should show task counts in column headers" do
    get kanban_project_url(@project)
    assert_response :success

    todo_count = @project.tasks.where(status: "todo").count
    in_progress_count = @project.tasks.where(status: "in_progress").count
    done_count = @project.tasks.where(status: "done").count

    assert_select ".card-header .badge", count: 3

    assert_select ".card-header:has(.badge:contains('#{todo_count}'))"

    assert_select ".card-header:has(.badge:contains('#{in_progress_count}'))"

    assert_select ".card-header:has(.badge:contains('#{done_count}'))"
  end

  test "should display empty state for columns with no tasks" do
    empty_project = @user.organization.projects.create!(
      title: "Empty Project",
      description: "A project with no tasks"
    )
    empty_project.project_memberships.create!(user: @user)

    get kanban_project_url(empty_project)
    assert_response :success

    assert_match "No tasks in this column", @response.body
  end

  test "should only show tasks from the specific project" do
    other_project = projects(:mobile_app)

    get kanban_project_url(@project)
    assert_response :success

    other_project.tasks.each do |task|
      refute_match task.title, @response.body
    end
  end

  test "should include new task button" do
    get kanban_project_url(@project)
    assert_response :success

    assert_match "New Task", @response.body
    assert_match new_task_path(project_id: @project.id), @response.body
  end

  test "should show correct task counts in each column" do
    todo_count = @project.tasks.where(status: "todo").count
    in_progress_count = @project.tasks.where(status: "in_progress").count
    done_count = @project.tasks.where(status: "done").count

    get kanban_project_url(@project)
    assert_response :success

    assert_select ".card-header .badge", count: 3
    assert_select ".card-header:has(.badge:contains('#{todo_count}'))"
    assert_select ".card-header:has(.badge:contains('#{in_progress_count}'))"
    assert_select ".card-header:has(.badge:contains('#{done_count}'))"
  end
end
