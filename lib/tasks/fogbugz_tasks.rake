desc 'Fogbugz Milestone Check'
task :milestone_check => :environment do
  Fogbugz.create_milestone_case
end
