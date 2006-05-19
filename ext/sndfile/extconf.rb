require 'mkmf'
system 'swig -ruby sndfile.i'
unless find_library 'sndfile', 'sf_open'
  error 'You need to install libsndfile'
  exit
end
dir_config 'narray', CONFIG['sitearchdir'], CONFIG['sitearchdir']
unless have_header 'narray.h'
  error 'You need to install NArray'
  exit
end
create_makefile 'sndfile'
