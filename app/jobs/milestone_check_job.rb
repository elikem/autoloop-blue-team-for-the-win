class MilestoneCheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Fogbugz.create_milestone_case
  end
end