#ifndef EAGL_EAGL_H
#define EAGL_EAGL_H

#ifdef __cplusplus
extern "C" {
#endif
void *EAGL_CreateContext();
void EAGL_DestroyContext(void *context);
void *EAGL_UseContext(void *context);
#ifdef __cplusplus
}
#endif

#endif /* EAGL_EAGL_H */
