//
//  sndscope.h
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#ifndef sndscope_sndscope_h
#define sndscope_sndscope_h

#include <stdio.h>
#include <stdlib.h>
#include "sndfile.h"

typedef struct scope_t {
    int samplerate;
    double starttime;
    float *buf;
    int buf_len;
    int buf_end;
} scope_t;

scope_t *scope_load(const char *);
void scope_start(scope_t *);
//void scope_get(scope_t *, float[]);
void scope_getr(scope_t *, float**, int*, float time);

void scope_free(scope_t *);

#endif
