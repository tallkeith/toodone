require "too_done/version"
require "too_done/init_db"
require "too_done/user"
require "too_done/session"
require "too_done/todo_list"
require "too_done/task"

require "thor"
require "pry"

module TooDone
  class App < Thor

    desc "add 'TASK'", "Add a TASK to a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which the task will be filed under."
    option :date, :aliases => :d,
      :desc => "A Due Date in YYYY-MM-DD format."
    def add(task)
      list = TodoList.find_or_create_by(list_name: options[:list], 
                                       user_id: current_user.id)
      new_task = Task.create(task_name: task, 
                             due_date: options[:due_date],
                             todo_list_id: list.id)
      puts "You created '#{new_task.task_name}' in your '#{list.list_name.capitalize}' list."
    end

    desc "edit", "Edit a task from a todo list."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be edited."
    def edit
      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one to edit
      # allow the user to change the title, due date
      list = TodoList.find_by(list_name: list)
      unless list
        puts "#{options[:list]} is not a valid list for #{current_user.name}"
        exit
      end

      tasks = Task.where(list_id: list.id)
      unless task.count > 0
        puts "No tasks found."
        exit
      end

      tasks.each do
        puts "#{tasks.id}, #{tasks.name}, #{tasks.item}, #{tasks.due_date}, #{tasks.completed}, #{tasks.list_id}, \n"
      end

      puts "Which task would you like to edit? (Input task ID)"
      edit = STDIN.gets.chomp.to_i
      puts "New title: "
      title_update = STDIN.gets.chomp
      puts "New Due Date (YYYY-MM-DD): "
      new_due = STDIN.gets.chomp
      task_to_edit = Task.find_by(id: edit)
      updated_task = task_to_edit.update_attributes(task_name: title_update, due_date: new_due)      
    end

    desc "done", "Mark a task as completed."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be completed."
    def done
      # find the right todo list
      # BAIL if it doesn't exist and have tasks
      # display the tasks and prompt for which one(s?) to mark done

      list = current_user.lists.find_by(list_name: options[:list])
      unless list && list.tasks.count >= 0
        puts "List has no tasks or does not exist"
        exit
      end

      Task.where(list_id: list.id).each {|x| puts "#{x.id}: #{x.task_name}"}
      puts "Which task number have you completed?"
      choice = STDIN.gets.chomp.to_i
      task = Task.find(choice)
      done = task.update_attributes(completed: true)
    end

    desc "show", "Show the tasks on a todo list in reverse order."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list whose tasks will be shown."
    option :completed, :aliases => :c, :default => false, :type => :boolean,
      :desc => "Whether or not to show already completed tasks."
    option :sort, :aliases => :s, :enum => ['history', 'overdue'],
      :desc => "Sorting by 'history' (chronological) or 'overdue'.
      \t\t\t\t\tLimits results to those with a due date."
    def show
      list = TodoList.find_or_create_by(list_name: options[:list], 
                                       user_id: current_user.id)
      show_tasks = Task.where(todo_list_id: list.id)
      puts list.show_tasks.task_name

      # find or create the right todo list
      # show the tasks ordered as requested, default to reverse order (recently entered first)
    end

    desc "delete [LIST OR USER]", "Delete a todo list or a user."
    option :list, :aliases => :l, :default => "*default*",
      :desc => "The todo list which will be deleted (including items)."
    option :user, :aliases => :u,
      :desc => "The user which will be deleted (including lists and items)."
    def delete
      # BAIL if both list and user options are provided
      # BAIL if neither list or user option is provided
      # find the matching user or list
      # BAIL if the user or list couldn't be found
      # delete them (and any dependents)

      unless option[:todo_list] && option[:user]
        if user = User.find_by(name: options[:user])
            user.destroy.all
        else list = TodoLists.where(list_name: options[:todo_list])
            list.destory.all
        end
      exit
      end
    end

    desc "switch USER", "Switch session to manage USER's todo lists."
    def switch(username)
      user = User.find_or_create_by(name: username)
      user.sessions.create
    end

    private
    def current_user
      Session.last.user
    end
  end
end

TooDone::App.start(ARGV)
