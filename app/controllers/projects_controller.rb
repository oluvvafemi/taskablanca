class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy kanban]

  def index
    @projects = Current.user.projects.includes(:organization, :tasks)
  end

  def show
    @tasks = @project.tasks.includes(:users).order(created_at: :desc)
  end

  def kanban
    @tasks = @project.tasks.includes(:users).order(created_at: :desc)
    @todo_tasks = @tasks.where(status: :todo)
    @in_progress_tasks = @tasks.where(status: :in_progress)
    @done_tasks = @tasks.where(status: :done)
  end

  def new
    @project = Current.user.organization.projects.build
  end

  def create
    @project = Current.user.organization.projects.build(project_params)

    if @project.save
      @project.project_memberships.create(user: Current.user)
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully deleted."
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Project not found or you don't have access."
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
