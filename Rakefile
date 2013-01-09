require "cucumber/rake/task"
require "rspec/core"
require "rspec/core/rake_task"


task :default => :run


task :run do
  sh "trema run ./topology-controller.rb -c network.conf"
end


RSpec::Core::RakeTask.new( :spec ) do | spec |
  spec.pattern = FileList[ "spec/**/*_spec.rb" ]
end


Cucumber::Rake::Task.new do | t |
  t.cucumber_opts = "features --tags ~@wip"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
