#include <ruby.h>
#include "scanner.h"

#define HASH_SET(H,K,V)  rb_hash_aset(H, ID2SYM(rb_intern(K)), V)

#if DEBUG
#define HERE fprintf(stderr, "[HERE] %s:%d:%s\n", __FILE__, __LINE__, __FUNCTION__)
#define M(N,I) fprintf(stderr, "[!] %s is at %d\n", N, I)
#define INSPECT(V) fprintf(stderr, "[?] %s\n", RSTRING(rb_inspect(V))->ptr)
#else
#define HERE
#define M(N,I)
#define INSPECT(V)
#endif

%%{
  machine saga_scanner;
  
  ## Actions
  
  action mark_start_token {
    state->start_of_token = fpc;
    M("start generic token", fpc - input);
  }
  
  ## Story actions
  
  action mark_start_role {
    state->story_markers[0] = fpc;
    M("begin role", fpc - input);
  }
  
  action mark_end_role {
    state->story_markers[1] = fpc;
    M("end role", fpc - input);
  }
  
  action mark_start_task {
    state->story_markers[2] = fpc;
    M("begin task", fpc - input);
  }
  
  action mark_end_task {
    /* Because the FSM can't distinguish between the start of the 'so that' keyphrase and an uchar
     * we only set the End Task Marker when there is no Start Reason Marker yet.
     */
    if (state->story_markers[4] == NULL) {
      state->story_markers[3] = fpc;
      M("end task", fpc - input);
    }
  }
  
  action mark_start_reason {
    state->story_markers[4] = fpc;
    M("begin reason", fpc - input);
  }
  
  action mark_end_reason {
    state->story_markers[5] = fpc;
    M("end reason", fpc - input);
  }
  
  action push_story_id {
    if (state->story_attributes == Qnil) state->story_attributes = rb_hash_new();
    
    HASH_SET(state->story_attributes, "id", rb_str_new(state->start_of_token, fpc - state->start_of_token));
    M("end story_id", fpc - input);
  }
  
  action push_story {
    
    if (state->story_attributes == Qnil) state->story_attributes = rb_hash_new();
    
    HASH_SET(state->story_attributes, "role", rb_str_new(state->story_markers[0], state->story_markers[1] - state->story_markers[0]));
    HASH_SET(state->story_attributes, "task", rb_str_new(state->story_markers[2], state->story_markers[3] - state->story_markers[2]));
    HASH_SET(state->story_attributes, "reason", rb_str_new(state->story_markers[4], state->story_markers[5] - state->story_markers[4]));
    rb_funcall(state->parser, rb_intern("handle_story"), 1, state->story_attributes);
    
    saga_scanner_reset_markers(state);
    M("push role", fpc - input);
  }
  
  ## State machine definition
  
  # Characters
  
  LF      = "\n";
  CRLF    = "\r\n";
  NEWLINE = LF | CRLF;
  SPACE   = " ";
  DOT     = ".";
  uchar   = (ascii | extend | SPACE);
  
  # A story
  
  as_a            = 'As a';
  as_an           = 'As an';
  as_a_an         = as_a | as_an;
  role            = uchar+             >mark_start_role %mark_end_role;
  i_would_like_to = 'I would like to';
  task            = uchar+             >mark_start_task %mark_end_task;
  so_that         = 'so that';
  reason          = uchar+             >mark_start_reason %mark_end_reason;
  story_body      = as_a_an role i_would_like_to task so_that reason DOT;
  
  story_id        = '#' (digit+)       >mark_start_token %push_story_id;
  attributes      = story_id;
  
  story           = story_body ( SPACE+ '-' SPACE+ attributes)? %push_story;
  
  main := (story NEWLINE)* story?;
  
  write data;
}%%

void saga_scanner_reset_markers(scanner_state *state)
{
  int i;
  
  state->start_of_token = NULL;
  state->story_attributes = Qnil;
  for (i = 0; i < 6; i++) {
    state->story_markers[i] = NULL;
  }
}

int saga_scanner_init(scanner_state *state, VALUE parser)
{
  int cs = 0;
  int eof = 0;
  
  %% write init;
  
  state->parser = parser;
  
  state->cs = cs;
  saga_scanner_reset_markers(state);
  
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
