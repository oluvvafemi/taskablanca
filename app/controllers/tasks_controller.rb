class TasksController < ApplicationController
  def index
    @tasks = Current.user.tasks.includes(:project)
  end
end
