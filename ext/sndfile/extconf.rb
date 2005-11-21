require 'mkmf'
system 'swig -ruby sndfile.i'
$libs = append_library $libs, 'sndfile'
create_makefile 'sndfile'
