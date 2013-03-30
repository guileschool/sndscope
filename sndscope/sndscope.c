//
//  sndscope
//  sndscope
//
//  Created by Nico Kreipke on 29.03.13.
//  Copyright (c) 2013 Nico Kreipke. All rights reserved.
//

#include "sndscope.h"
#include <sys/time.h>
#include <strings.h>

double seconds_from_timeval(struct timeval t) {
    double s = t.tv_sec;
//    printf("%f",s);
    s += ((double)t.tv_usec / 1000000.0);
    return s;
}


scope_t *scope_load(const char *path) {
    scope_t *sc = (scope_t*)malloc(sizeof(scope_t));
    SF_INFO info;
    SNDFILE *s = sf_open(path, SFM_READ, &info);
    sc->samplerate = info.samplerate;
    sc->buf_len = 2000;
    sc->buf = (float*)malloc(sizeof(float) * sc->buf_len);
    if (!sc->buf) {
        printf("memory!\n");
        sf_close(s);
        return NULL;
    }
    
    int bufpt = 0;
    
    int channels = info.channels;
    if (channels < 2) {
        printf("too few channels\n");
        sf_close(s);
        return NULL;
    }
    
    sf_count_t rc;
    float b[channels];
    while ((rc = sf_readf_float(s, b, 1)) == 1) {
        if (bufpt >= sc->buf_len) {
            sc->buf_len += 2000;
            float * nb = (float*)realloc((void*)sc->buf, sizeof(float) * sc->buf_len);
            if (!nb) {
                printf("memory!\n");
                sf_close(s);
                return NULL;
            }
            sc->buf = nb;
        }
        *(sc->buf + bufpt) = b[0];
        *(sc->buf + bufpt + 1) = b[1];
        bufpt += 2;
    }
    sc->buf_end = bufpt;
    sf_close(s);
//    printf("success\n");
    return sc;
}

void scope_start(scope_t *s) {
    struct timeval t;
    gettimeofday(&t, NULL);
    s->starttime = seconds_from_timeval(t);
}

//void scope_get(scope_t *s, float data[]) {
//    clock_t c = clock() - s->starttime;
//    int sampleindex = (int)(c / s->cpu_tick_interval);
//    if (sampleindex*2+1 > s->buf_end) {
//        data[0] = -1000.0f;
//        return;
//    }
//    data[0] = *(s->buf + (sampleindex * 2));
//    data[1] = *(s->buf + (sampleindex * 2) + 1);
//}

void scope_getr(scope_t *s, float **data, int *dlen, float time) {
    struct timeval t;
    gettimeofday(&t, NULL);
    double seconds = seconds_from_timeval(t) - s->starttime;
//    printf("seconds: %f\n",seconds);
    int sampleindex = (int)(seconds * (double)s->samplerate);
//    c *= 7;
//    time *= 2;
//    int sampleindex = (int)(c / s->cpu_tick_interval);
    sampleindex *= 2;
    int samplecount = time / s->sample_interval;
    *dlen = samplecount * 2;
    float *d = (float*)malloc(*dlen * sizeof(float));
    bzero((void*)d, *dlen);
    if (!d) {
        printf("memory!\n");
        *data = NULL;
        return;
    }
    if ((sampleindex + samplecount) > s->buf_end) {
//        printf("buf end!\n");
        *data = NULL;
        return;
    }
    int i;
    for (i = 0; i < samplecount; i++) {
        int ir = 2*i;
        int sind = sampleindex + ir;
        *(d+ir) = 1.0f + ((1.0f + (*(s->buf + sind))) / -2.0f);
        *(d+ir+1) = 1.0f + ((1.0f + (*(s->buf + sind + 1))) / -2.0f);
    }
//    printf("done filling size %i until %i: sc %i\n",*dlen,2*i, samplecount);
    *data = d;
}

void scope_free(scope_t *s) {
    if (!s) {
        return;
    }
    if (s->buf) {
        free(s->buf);
    }
    free(s);
}