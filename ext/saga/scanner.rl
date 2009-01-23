#include <ruby.h>

%%{
  machine saga_scanner;
  
  # A story
  
  as_a    = 'As a';
  as_an   = 'As an';
  as_a_an = as_a | as_an;
  role    = any*;
  
  main := as_a_an role;
  
  write data;
}%%

static VALUE saga_scanner_scan(VALUE self, VALUE parser, VALUE input)
{
  int cs;
  
  StringValue(input);
  
  %% write init;
  
  char *p = StringValuePtr(input);
  char *pe = p + RSTRING(input)->len;
  
  %% write exec;
  
  return Qnil;
}

void Init_scanner()
{
  VALUE mSaga    = rb_define_module("Saga");
  VALUE mScanner = rb_define_module_under(mSaga, "Scanner");
  
  rb_define_module_function(mScanner, "scan", saga_scanner_scan, 2);
}