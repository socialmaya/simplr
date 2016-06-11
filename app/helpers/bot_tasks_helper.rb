module BotTasksHelper
  def bot_creation_amount_options
    options = [["Choose amount of bots to create", nil]]
    (0..100).step(10) do |n|
      options << n
    end
    return options
  end
  
  def bot_task_type_options
    options = [["Choose a task type", nil]]
    BotTask.task_types.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
end
