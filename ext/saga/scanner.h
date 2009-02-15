#ifndef scanner_h
#define scanner_h

#include <sys/types.h>

typedef struct scanner_state {
  VALUE parser;
  
  int cs;
  const char *story_markers[6];
  const char *start_of_token;
} scanner_state;

int saga_scanner_init(scanner_state *state, VALUE parser);
void saga_scanner_reset_markers(scanner_state *state);
int saga_scanner_execute(scanner_state *state, const char *input, size_t input_length);
int saga_scanner_finish(scanner_state *state);

#endif