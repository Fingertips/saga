#include <ruby.h>
#include "scanner.h"

#define HERE fprintf(stderr, "[HERE] %s:%d:%s\n", __FILE__, __LINE__, __FUNCTION__)

void handle_role(void *self, const char *p)
{
  scanner_state *state = (scanner_state *)self;
  rb_funcall(state->parser, rb_intern("handle_role"), 1, rb_str_new(state->start_of_token, p - state->start_of_token));
}

%%{
  machine saga_scanner;
  
  ## Actions
  
  action mark_begin_token {
    state->start_of_token = fpc;
  }
  
  action clear_arguments {
  }
  
  action push_role_argument {
    state->handle_role(state, p);
  }
  
  action push_story {
  }
  
  ## State machine definition
  
  # Characters
  
  LF = "\n";
  CRLF = "\r\n";
  NEWLINE = LF | CRLF;
  WHITESPACE = " ";
  
  # A story
  
  as_a    = 'As a';
  as_an   = 'As an';
  as_a_an = as_a | as_an;
  role    = any*                       >mark_begin_token %push_role_argument;
  story   = as_a_an WHITESPACE* role   >clear_arguments  %push_story;
  
  main := story NEWLINE;
  
  write data;
}%%

int saga_scanner_init(scanner_state *state, VALUE parser)
{
  int cs = 0;
  int eof = 0;
  %% write init;
  state->cs = cs;
  state->start_of_token = 0;
  state->parser = parser;
  state->handle_role = handle_role;
  
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
  free(state);
  
  return(1);
}

static VALUE saga_scanner_scan(VALUE self, VALUE parser, VALUE input)
{
  if (parser != Qnil) {
    scanner_state *state = ALLOC_N(scanner_state, 1);
    
    StringValue(input);
    
    if (saga_scanner_init(state, parser)) {
      saga_scanner_execute(state, StringValuePtr(input), RSTRING(input)->len);
      saga_scanner_finish(state);
    }
  } else {
    rb_raise(rb_eArgError, "Please specify a parser to parse too.");
  }
  
  return Qnil;
}

void Init_scanner()
{
  VALUE mSaga    = rb_define_module("Saga");
  VALUE mScanner = rb_define_module_under(mSaga, "Scanner");
  
  rb_define_module_function(mScanner, "scan", saga_scanner_scan, 2);
}
