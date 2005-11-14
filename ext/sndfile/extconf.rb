require 'mkmf'
$libs = append_library $libs, 'sndfile'
create_makefile 'sndfile'
