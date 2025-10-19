require "test_helper"

class TaskAssignmentTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    assignment = task_assignments(:alice_design)
    assert assignment.valid?
  end

  test "belongs to user" do
    assignment = task_assignments(:alice_design)
    assert_instance_of User, assignment.user
    assert_equal users(:alice), assignment.user
  end

  test "belongs to task" do
    assignment = task_assignments(:alice_design)
    assert_instance_of Task, assignment.task
    assert_equal tasks(:design_mockups), assignment.task
  end

  test "can create valid assignment" do
    user = users(:bob)
    task = tasks(:implement_navbar)

    assignment = TaskAssignment.new(user: user, task: task)
    assert assignment.valid?
    assert assignment.save
  end

  test "user can access task after assignment is created" do
    user = users(:diana)
    task = tasks(:design_mockups)

    assert_not_includes user.tasks, task

    TaskAssignment.create!(user: user, task: task)
    user.reload

    assert_includes user.tasks, task
  end

  test "can assign user to task from different organization" do
    diana = users(:diana)
    acme_task = tasks(:design_mockups)

    assignment = TaskAssignment.new(user: diana, task: acme_task)
    assert assignment.valid?
  end
end
