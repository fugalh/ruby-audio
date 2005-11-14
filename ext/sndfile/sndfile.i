// TODO: sf_command,
%module "audio::sndfile"
%{
#include "sndfile.h"
%}

%include "typemaps.i"
%typemap(out) int sf_format_check {
  if ($1)
    $result = Qtrue;
  else
    $result = Qfalse;
}

%typemap(out) sf_count_t {
  $result = INT2NUM($1);
}
%typemap(in) sf_count_t {
  $1 = (sf_count_t) NUM2INT($input);
}
//%typemap(in) short *ptr {
    // convert from NArray or Sound or something. likewise for int, float,
    // double.
//}

// sf_perror and sf_error_str are deprecated. sf_error_str probably doesn't
// work at all.

%include "sndfile.h"
