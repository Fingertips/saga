#include <ruby.h>
#include "scanner.h"

%%{
  machine saga_scanner;
  
  ## Actions
  
  action mark_begin_token {
  }
  
  action clear_arguments {
  }
  
  action push_role_argument {
  }
  
  action push_story {
  }
  
  ## State machine definition
  
  # A story
  
  as_a    = 'As a';
  as_an   = 'As an';
  as_a_an = as_a | as_an;
  role    = any*           >mark_begin_token %push_role_argument;
  story   = as_a_an role   >clear_arguments  %push_story;
  
  main := story;
  
  write data;
}%%

int saga_scanner_init(scanner_state *state)
{
  int cs = 0;
  int eof = 0;
  %% write init;
  state->cs = cs;
  state->start_of_token = 0;
  
  return(1);
}

int saga_scanner_execute(scanner_state *state, const char *input)  {
  const char *p = NULL;
  const char *pe = NULL;
  const char *eof = NULL;
  int cs = state->cs;
  
  p = input;
  %% write exec;
  state->cs = cs;

  return(1);
}

int saga_scanner_finish(scanner_state *state)
{
  return(1);
}

static VALUE saga_scanner_scan(VALUE self, VALUE parser, VALUE input)
{
  scanner_state *state = NULL;
  StringValue(input);
  
  if (saga_scanner_init(state)) {
    saga_scanner_execute(state, StringValuePtr(input));
    saga_scanner_finish(state);
  }
  
  return Qnil;
}

void Init_scanner()
{
  VALUE mSaga    = rb_define_module("Saga");
  VALUE mScanner = rb_define_module_under(mSaga, "Scanner");
  
  rb_define_module_function(mScanner, "scan", saga_scanner_scan, 2);}