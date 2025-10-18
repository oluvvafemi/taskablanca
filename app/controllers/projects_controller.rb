class ProjectsController < ApplicationController
  def index
    @projects = Current.user.projects.includes(:organization, :tasks)
  end
end
