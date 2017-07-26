class HomeController < ApplicationController
  def index
    @cases_created_today = Fogbugz.get_cases
    @most_recent_case = Fogbugz.most_recent_case['ixBug']
    @cases_to_milestone = Fogbugz.cases_to_milestone
  end
end
