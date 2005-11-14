desc "RDoc documentation"
task :doc do
  sh 'rdoc -t "ruby-audio" -m Audio lib'
end

file 'ext/sndfile/sndfile_wrap.c' => ['ext/sndfile/sndfile.i'] do
  sh 'cd ext/sndfile; swig -ruby sndfile.i'
end

task :sndfile => ['ext/sndfile/sndfile_wrap.c'] do
  sh 'make -C ext/sndfile'
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs += ['ext/sndfile']
end
