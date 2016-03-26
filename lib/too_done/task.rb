module TooDone
  class Task < ActiveRecord::Base
    belongs_to :todo_list
  end
end
