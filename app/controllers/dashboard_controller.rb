class DashboardController < ApplicationController
  def show
    @user = Current.user
    @projects = @user.projects.includes(:tasks)
    @tasks = @user.tasks.includes(:project)

    @total_projects = @projects.count
    @total_tasks = @tasks.count
    @todo_tasks = @tasks.where(status: "todo").count
    @in_progress_tasks = @tasks.where(status: "in_progress").count
    @done_tasks = @tasks.where(status: "done").count
  end
end
