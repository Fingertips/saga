#include <ruby.h>
#include "scanner.h"

%%{
  machine saga_scanner;
  
  ## Actions
  
  action mark_begin_token {
    printf("=> Mark begin token\n");
  }
  
  action clear_arguments {
    printf("=> Clear arguments\n");
  }
  
  action push_role_argument {
    printf("<= Push role argument\n");
  }
  
  action push_story {
    printf("<= Push story\n");
  }
  
  ## State machine definition
  
  # Characters
  
  LF = "\n";
  CRLF = "\r\n";
  NEWLINE = LF | CRLF;
  
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

int saga_scanner_execute(scanner_state *state, const char *input, size_t input_length)  {
  const char *p = NULL;
  const char *pe = NULL;
  const char *eof = NULL;
  int cs = state->cs;
  
  p = input;
  pe = input + input_length;
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
  scanner_state *state = ALLOC_N(scanner_state, 1);
  
  StringValue(input);
  
  if (saga_scanner_init(state)) {
    saga_scanner_execute(state, StringValuePtr(input), RSTRING(input)->len);
    saga_scanner_finish(state);
  }
  
  return Qnil;
}

void Init_scanner()
{
  VALUE mSaga    = rb_define_module("Saga");
  VALUE mScanner = rb_define_module_under(mSaga, "Scanner");
  
  rb_define_module_function(mScanner, "scan", saga_scanner_scan, 2);
}
