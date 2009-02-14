#ifndef scanner_h
#define scanner_h

#include <sys/types.h>

typedef void (*push_function)(void *self, const char *p);

typedef struct scanner_state {
  
  int cs;
  const char *start_of_token;
  
  VALUE parser;
  
  push_function handle_role;
  
} scanner_state;

int saga_scanner_init(scanner_state *state, VALUE parser);
int saga_scanner_execute(scanner_state *state, const char *input, size_t input_length);
int saga_scanner_finish(scanner_state *state);

#endif