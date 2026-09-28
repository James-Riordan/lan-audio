#define _POSIX_C_SOURCE 200809L
#include "platform.h"
#include <time.h>
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <avrt.h>
int la_audio_task_enter(uintptr_t *task) {
    if (!task || *task) return -1;
    DWORD index = 0;
    HANDLE handle = AvSetMmThreadCharacteristicsW(L"Audio", &index);
    if (!handle) return -1;
    *task = (uintptr_t)handle;
    return 0;
}
int la_audio_task_leave(uintptr_t *task) {
    if (!task) return -1;
    if (*task && !AvRevertMmThreadCharacteristics((HANDLE)*task)) return -1;
    *task = 0;
    return 0;
}
static void (*stop_hook)(int);
static int installed;
static BOOL WINAPI control(DWORD event) {
    if (event == CTRL_C_EVENT || event == CTRL_BREAK_EVENT || event == CTRL_CLOSE_EVENT) {
        if (stop_hook) stop_hook(event != CTRL_C_EVENT);
        return TRUE;
    }
    return FALSE;
}
int la_control_install(void (*hook)(int)) {
    if (!hook || installed || (stop_hook && stop_hook != hook)) return -1;
    if (!stop_hook) stop_hook = hook;
    if (!SetConsoleCtrlHandler(control, TRUE)) return -1;
    installed = 1;
    return 0;
}
void la_control_restore(void) {
    /* The hook points to process-lifetime code/static atomics. A callback already
       dispatched by Windows can safely finish after deregistration. */
    if (installed && SetConsoleCtrlHandler(control, FALSE)) installed = 0;
}
int la_pacer_init(la_pacer *p) {
    p->timer = (uintptr_t)CreateWaitableTimerExW(NULL, NULL, 0x00000002, TIMER_ALL_ACCESS);
    if (!p->timer) p->timer = (uintptr_t)CreateWaitableTimerExW(NULL, NULL, 0, TIMER_ALL_ACCESS);
    return p->timer ? 0 : -1;
}
int la_pacer_wait(la_pacer *p, unsigned ms) {
    if (!p->timer || ms == 0 || ms > 1000) return -1;
    LARGE_INTEGER due;
    due.QuadPart = -(LONGLONG)ms * 10000;
    if (!SetWaitableTimer((HANDLE)p->timer, &due, 0, NULL, NULL, FALSE)) return -1;
    return WaitForSingleObject((HANDLE)p->timer, ms + 1000) == WAIT_OBJECT_0 ? 0 : -1;
}
void la_pacer_close(la_pacer *p) {
    if (p->timer) { CloseHandle((HANDLE)p->timer); p->timer = 0; }
}
#else
#include <errno.h>
#include <signal.h>
int la_audio_task_enter(uintptr_t *task) { (void)task; return -1; }
int la_audio_task_leave(uintptr_t *task) { return task && !*task ? 0 : -1; }
static void (*stop_hook)(int);
static struct sigaction old_int, old_term;
static int installed;
static void control(int event) { if (stop_hook) stop_hook(event == SIGTERM); }
int la_control_install(void (*hook)(int)) {
    if (!hook || installed) return -1;
    struct sigaction action = {0};
    action.sa_handler = control;
    sigemptyset(&action.sa_mask);
    stop_hook = hook;
    if (sigaction(SIGINT, &action, &old_int)) return -1;
    if (sigaction(SIGTERM, &action, &old_term)) { sigaction(SIGINT, &old_int, NULL); return -1; }
    installed = 1;
    return 0;
}
void la_control_restore(void) {
    if (installed) { sigaction(SIGINT, &old_int, NULL); sigaction(SIGTERM, &old_term, NULL); installed = 0; }
}
int la_pacer_init(la_pacer *p) { p->timer = 1; return 0; }
int la_pacer_wait(la_pacer *p, unsigned ms) {
    if (!p->timer || ms == 0 || ms > 1000) return -1;
    struct timespec delay = { (time_t)(ms / 1000), (long)(ms % 1000) * 1000000 };
    while (nanosleep(&delay, &delay)) if (errno != EINTR) return -1;
    return 0;
}
void la_pacer_close(la_pacer *p) { p->timer = 0; }
#endif
int64_t la_wall_seconds(void) { return (int64_t)time(NULL); }
