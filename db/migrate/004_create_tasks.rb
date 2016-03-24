class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
    	t.integer :todo_list_id, null: false
      t.string :task_name, null: false
      t.boolean :completed, default: false
      t.date :due_date
      t.timestamps
    end

    add_column(:todo_lists, :user_id, :integer)
  end

  

  def down
    drop_table :tasks
    remove_column(:todo_lists, :user_id)
  end
end

