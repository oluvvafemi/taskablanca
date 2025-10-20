require "test_helper"

class TasksKanbanFunctionalityTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:alice)
    @project = projects(:website_redesign)
    sign_in_as(@user)
  end

  test "should display task information in kanban cards" do
    get kanban_project_url(@project)
    assert_response :success

    @project.tasks.each do |task|
      case task.status
      when "todo"
        assert_select "#todo_tasks", text: /#{Regexp.escape(task.title)}/
      when "in_progress"
        assert_select "#in_progress_tasks", text: /#{Regexp.escape(task.title)}/
      when "done"
        assert_select "#done_tasks", text: /#{Regexp.escape(task.title)}/
      end

      if task.users.any?
        task.users.each do |user|
          case task.status
          when "todo"
            assert_select "#todo_tasks", text: /#{Regexp.escape(user.name)}/
          when "in_progress"
            assert_select "#in_progress_tasks", text: /#{Regexp.escape(user.name)}/
          when "done"
            assert_select "#done_tasks", text: /#{Regexp.escape(user.name)}/
          end
        end
      end
    end
  end

  test "should display unassigned tasks correctly" do
    unassigned_task = @project.tasks.create!(
      title: "Unassigned Task",
      description: "A task with no assignments",
      status: "todo"
    )

    get kanban_project_url(@project)
    assert_response :success

    assert_select "#todo_tasks", text: /#{Regexp.escape(unassigned_task.title)}/
    assert_select "#todo_tasks", text: /Unassigned/
  end

  test "should show correct buttons for todo status tasks" do
    task = @project.tasks.create!(
      title: "Todo Task",
      description: "A todo task",
      status: "todo"
    )
    task.task_assignments.create!(user: @user)

    get kanban_project_url(@project)
    assert_response :success

    assert_select "#todo_tasks .bi-play"
    assert_select "#todo_tasks .bi-check"

    assert_select "#todo_tasks .bi-arrow-counterclockwise", count: 0
  end

  test "should show correct buttons for in_progress status tasks" do
    task = @project.tasks.create!(
      title: "Progress Task",
      description: "An in-progress task",
      status: "in_progress"
    )
    task.task_assignments.create!(user: @user)

    get kanban_project_url(@project)
    assert_response :success

    assert_select "#in_progress_tasks .bi-arrow-counterclockwise"
    assert_select "#in_progress_tasks .bi-check"
    assert_select "#in_progress_tasks .bi-play", count: 0
  end

  test "should show correct buttons for done status tasks" do
    task = @project.tasks.create!(
      title: "Done Task",
      description: "A completed task",
      status: "done"
    )
    task.task_assignments.create!(user: @user)

    get kanban_project_url(@project)
    assert_response :success

    assert_select "#done_tasks .bi-arrow-counterclockwise"
    assert_select "#done_tasks .bi-play", count: 0
    assert_select "#done_tasks .bi-check", count: 0
  end

  test "should display empty state for columns with no tasks" do
    empty_project = @user.organizations.first.projects.create!(
      title: "Empty Project",
      description: "A project with no tasks"
    )
    empty_project.project_memberships.create!(user: @user)

    get kanban_project_url(empty_project)
    assert_response :success

    assert_select "#todo_tasks", text: /No tasks in this column/
    assert_select "#in_progress_tasks", text: /No tasks in this column/
    assert_select "#done_tasks", text: /No tasks in this column/
    assert_select "#todo_tasks .bi-inbox"
  end
end
