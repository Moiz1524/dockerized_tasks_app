class TaskCreatedJob < ApplicationJob
  queue_as :default

  def perform(task)
    TaskMailer.task_created(task).deliver_later
  end
end
