module TooDone
  class TodoList < ActiveRecord::Base
    belongs_to :user
    has_many :tasks
  end
end
