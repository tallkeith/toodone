class CreateTodoLists < ActiveRecord::Migration
  def up
    create_table :todo_lists do |t|
      t.string :list_name, null: false
      t.timestamps
    end
  end

  def down
    drop_table :todo_list
  end
end

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         