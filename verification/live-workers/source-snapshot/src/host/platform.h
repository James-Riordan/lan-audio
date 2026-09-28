#ifndef LAN_AUDIO_PLATFORM_H
#define LAN_AUDIO_PLATFORM_H
#include <stdint.h>
typedef struct { uintptr_t timer; } la_pacer;
int la_pacer_init(la_pacer *p);
int la_pacer_wait(la_pacer *p, unsigned milliseconds);
void la_pacer_close(la_pacer *p);
int64_t la_wall_seconds(void);
/* Hook must only publish lock-free flags; process-wide foreground owner only. */
int la_control_install(void (*hook)(int urgent));
void la_control_restore(void);
#endif
