task :default => [:test, :doc]

task :install => [:setup] do
  sh 'ruby setup.rb install'
end


desc "RDoc documentation"
task :doc do
  sh 'rdoc -t "ruby-audio" -m README README lib'
end

file '.config' do
  sh 'ruby setup.rb config'
end

task :setup => ['.config'] do
  sh 'ruby setup.rb setup'
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs += ['ext/sndfile']
end
task :test => [:setup]

# vim: filetype=ruby
