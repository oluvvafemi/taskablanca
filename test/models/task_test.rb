require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    task = tasks(:design_mockups)
    assert task.valid?
  end

  test "should require title" do
    task = Task.new(description: "Test description", project: projects(:website_redesign))
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should require description" do
    task = Task.new(title: "Test task", project: projects(:website_redesign))
    assert_not task.valid?
    assert_includes task.errors[:description], "can't be blank"
  end

  test "should allow multiple tasks with same title in different projects" do
    task1 = tasks(:design_mockups)
    task2 = Task.new(
      title: task1.title,
      description: "Different project",
      project: projects(:mobile_app)
    )
    assert task2.valid?
  end

  test "should have default status of todo" do
    task = Task.new(title: "New task", description: "Test", project: projects(:website_redesign))
    assert_equal "todo", task.status
  end

  test "should accept valid status values" do
    task = tasks(:design_mockups)

    task.status = "todo"
    assert task.valid?

    task.status = "in_progress"
    assert task.valid?

    task.status = "done"
    assert task.valid?
  end

  test "should reject invalid status values" do
    task = tasks(:design_mockups)
    task.status = "invalid_status"
    assert_not task.valid?
    assert_includes task.errors[:status], "is not included in the list"
  end

  test "should scope tasks by status" do
    todo_tasks = Task.where(status: "todo")
    in_progress_tasks = Task.where(status: "in_progress")
    done_tasks = Task.where(status: "done")

    assert_includes todo_tasks, tasks(:design_mockups)
    assert_includes in_progress_tasks, tasks(:implement_navbar)
    assert_includes done_tasks, tasks(:setup_backend)
  end

  test "should belong to project" do
    task = tasks(:design_mockups)
    assert_instance_of Project, task.project
    assert_equal projects(:website_redesign), task.project
  end

  test "destroys associated task_assignments when task is destroyed" do
    org = Organization.create!(name: "Temp Org for Task Assignments")
    project = Project.create!(title: "Temp Project", description: "Desc", organization: org)
    task = Task.create!(title: "Temp Task", description: "Desc", project: project)
    user = User.create!(name: "Temp User", email_address: "temp_task_assign@example.com", password: "password", organization: org)
    task.task_assignments.create!(user: user)

    assert_difference "TaskAssignment.count", -1 do
      task.destroy
    end
  end

  test "destroying task does not destroy users" do
    task = tasks(:design_mockups)
    user = users(:bob)
    task.task_assignments.create!(user: user)

    task.destroy

    assert User.exists?(user.id)
  end

  test "belongs to organization through project" do
    task = tasks(:design_mockups)
    assert_equal organizations(:acme), task.project.organization
  end

  test "tasks are isolated by project" do
    website_project = projects(:website_redesign)
    mobile_project = projects(:mobile_app)

    website_task = website_project.tasks.create!(
      title: "Website Task",
      description: "Description"
    )
    mobile_task = mobile_project.tasks.create!(
      title: "Mobile Task",
      description: "Description"
    )

    assert_includes website_project.tasks, website_task
    assert_not_includes mobile_project.tasks, website_task

    assert_includes mobile_project.tasks, mobile_task
    assert_not_includes website_project.tasks, mobile_task
  end
end
