#include "../inc/fct_yacc.h"

void concat_data(char *dst, char *str2) {
    int initial_len = strlen(dst);
    int new_len = initial_len + strlen(str2);
    char *buf_dst;
    buf_dst = malloc(initial_len+1);
    snprintf(buf_dst,initial_len+1,"%s",dst);
    dst = realloc(dst,new_len);
    snprintf(dst,new_len+1,"%s%s",buf_dst,str2);
    dst[new_len] = '\0';
}