class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.string :priority, null: false, default: "medium"
      t.date :due_date

      t.timestamps
    end
  end
end
