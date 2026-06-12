class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy copy]

  def index
    @tasks = Task.all.recent
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      TaskCreatedJob.perform_later(@task)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("task_form", partial: "tasks/form", locals: { task: @task }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@task), partial: "tasks/task", locals: { task: @task, editing: true }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(helpers.dom_id(@task)) }
      format.html { redirect_to tasks_path, notice: "Task deleted." }
    end
  end

  def copy
    @new_task = @task.dup
    @new_task.title = "Copy of #{@task.title}"
    @new_task.status = "pending"
    @new_task.save!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.prepend("tasks_list", partial: "tasks/task", locals: { task: @new_task }) }
      format.html { redirect_to tasks_path, notice: "Task duplicated." }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date)
  end
end
