class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]
  before_action :load_projects, only: %i[new edit create update]

  def index
    @tasks = Current.user.tasks.includes(:project)
  end

  def show
  end

  def new
    @task = Task.new
    if params[:project_id]
      @project_inline_edit = true
      @project_id = params[:project_id]
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Project not found or you don't have access."
  end

  def create
    @task = Task.new(task_params)

    unless Current.user.projects.exists?(@task.project_id)
      redirect_to tasks_path, alert: "You don't have access to that project."
      return
    end

    if @task.save
      @task.task_assignments.create(user: Current.user)
      @project = @task.project
      set_tasks

      handle_kanban_context

      respond_to do |format|
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.turbo_stream
      end
    else
      @project = Current.user.projects.find(@task.project_id) if @task.project_id
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if params[:project_id]
      @project_inline_edit = true
      @project_id = params[:project_id]
    end
  end

  def update
    if @task.update(task_params)
      handle_kanban_context

      respond_to do |format|
        format.html { redirect_to @task, notice: "Task was successfully updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = @task.project
    @task.destroy
    set_tasks

    handle_kanban_context

    respond_to do |format|
      format.html { redirect_to project_path(@project), notice: "Task was successfully deleted." }
      format.turbo_stream
    end
  end

  private

  def set_task
    @task = Current.user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "Task not found or you don't have access."
  end

  def load_projects
    @projects = Current.user.projects.order(:title)
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :project_id)
  end

  def set_tasks
    @tasks = @project.tasks.includes(:users).order(created_at: :desc)
  end

  def kanban_context?
    request.referer&.include?("/kanban")
  end

  def handle_kanban_context
    @kanban_context = kanban_context?
    if @kanban_context
      @project = @task.project if @project.nil?
      load_kanban_data
    end
  end

  def load_kanban_data
    set_tasks if @tasks.nil?
    @todo_tasks = @tasks.where(status: :todo)
    @in_progress_tasks = @tasks.where(status: :in_progress)
    @done_tasks = @tasks.where(status: :done)
  end
end
