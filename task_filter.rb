class TaskFilter

  def filter(task_name, prio, current_date)
    #insert your code here
    
    if (prio < 0)
      prio = 9
    end
    
    return prio
  end
  
  # do not change this, this code is used for testing
  def self.default_filter
    task_filter = TaskFilter.new
    
    def task_filter.filter(task_name, prio, current_date);
      if (prio < 0)
        prio = 9
      end

      return prio
    end
    task_filter
  end
  
  
end