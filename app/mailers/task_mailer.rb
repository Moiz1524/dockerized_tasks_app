class TaskMailer < ApplicationMailer
  def task_created(task)
    @task = task
    mail(to: "moiz@example.co", subject: "New task created: #{task.title}")
  end
end
