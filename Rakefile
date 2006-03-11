task :default => [:test, :doc]

task :install => [:setup] do
  sh 'ruby setup.rb install'
end


desc "RDoc documentation"
task :doc do
  sh 'rdoc -T extras/flipbook_rdoc.rb -t "ruby-audio" -m README README lib'
end

file '.config' do
  sh 'ruby setup.rb config'
end

task :setup => ['.config'] do
  sh 'ruby setup.rb setup'
end

desc 'clean up'
task :clean do
  sh 'ruby setup.rb clean'
  sh 'rm -rf doc'
end

task :dist do
  sh 'darcs dist -d ruby-audio-`cat VERSION`'
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs += ['ext/sndfile']
end
task :test => [:setup]

# vim: filetype=ruby
