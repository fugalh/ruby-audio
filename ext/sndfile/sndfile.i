// TODO: sf_command,
%module "sndfile"
%{
#include "sndfile.h"
#include "narray.h"
%}

// this bit brought to you by stdio.h
#ifndef SEEK_SET
#define SEEK_SET        0       /* set file offset to offset */
#endif
#ifndef SEEK_CUR
#define SEEK_CUR        1       /* set file offset to current plus offset */
#endif
#ifndef SEEK_END
#define SEEK_END        2       /* set file offset to EOF plus offset */
#endif

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

// We have to do this or when a function like sf_get_string returns NULL it
// will raise an exception when trying to create the string.
%typemap(out) const char *{
    if ($1 == 0) 
	$result = Qnil;
    else
	$result = rb_str_new2($1);
}

%typemap(in) (short *ptr, sf_count_t),
    (const short *ptr, sf_count_t)
{
if (!(NA_IsNArray($input) && NA_TYPE($input) == NA_SINT)) 
    rb_raise(rb_eArgError, "Expected NArray.sint");
$1 = NA_PTR_TYPE($input, $1_type); 
$2 = NA_TOTAL($input);
}
%typemap(in) (int *ptr, sf_count_t),
    (const int *ptr, sf_count_t)
{
if (!(NA_IsNArray($input) && NA_TYPE($input) == NA_LINT))
	rb_raise(rb_eArgError, "Expected NArray.int");
$1 = NA_PTR_TYPE($input, $1_type); 
$2 = NA_TOTAL($input);
}
%typemap(in) (float *ptr, sf_count_t), 
    (const float *ptr, sf_count_t)
{
if (!(NA_IsNArray($input) && NA_TYPE($input) == NA_SFLOAT))
	rb_raise(rb_eArgError, "Expected NArray.sfloat");
$1 = NA_PTR_TYPE($input, $1_type); 
$2 = NA_TOTAL($input);
}
%typemap(in) (double *ptr, sf_count_t),
    (const double *ptr, sf_count_t)
{
if (!(NA_IsNArray($input) && NA_TYPE($input) == NA_DFLOAT))
	rb_raise(rb_eArgError, "Expected NArray.float");
$1 = NA_PTR_TYPE($input, $1_type); 
$2 = NA_TOTAL($input);
}

// sf_perror and sf_error_str are deprecated. sf_error_str probably doesn't
// work at all.

%include "sndfile.h"
// vim: filetype=c
