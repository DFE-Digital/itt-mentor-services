desc "Run the Good Job worker"
task :good_job_start do # rubocop:disable Rails/RakeEnvironment
  sh "good_job", "start"
end
