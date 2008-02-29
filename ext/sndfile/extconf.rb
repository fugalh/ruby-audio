require 'mkmf'
$CFLAGS = '-I/opt/local/include -I/usr/local/include'
$LDFLAGS = '-L/opt/local/lib -L/usr/local/lib'
system 'swig -ruby -I/usr/include -I/usr/local/include -I/opt/local/include sndfile.i'
unless find_library 'sndfile', 'sf_open'
  error 'You need to install libsndfile'
  exit
end
dir_config 'narray', CONFIG['sitearchdir'], CONFIG['sitearchdir']
# TODO /opt/local/lib/ruby/gems/1.8/gems/narray-0.5.9.4/narray.h
unless have_header 'narray.h'
  error 'You need to install NArray'
  exit
end
create_makefile 'sndfile'
