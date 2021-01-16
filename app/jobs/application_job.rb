class ApplicationJob < ActiveJob::Base
  queue_as :default

  def queue_name
    'default'
  end
end
