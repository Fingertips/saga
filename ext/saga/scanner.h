#ifndef scanner_h
#define scanner_h

#include <sys/types.h>

typedef struct scanner_state { 
  
  int cs;
  size_t start_of_token;
  
} scanner_state;

int scanner_init(scanner_state *state);
int saga_scanner_execute(scanner_state *state, const char *input, size_t input_length);
int scanner_finish(scanner_state *state);

#endif
