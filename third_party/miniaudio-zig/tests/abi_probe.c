/* Independent C facts for the translated Zig ABI. This file includes the adopted
 * profile, never MINIAUDIO_IMPLEMENTATION, and opens no context or device.
 * All results cross as primitive size_t/int values so an unverified probe struct
 * cannot make a layout comparison circular. Selector IDs are the test protocol
 * documented in docs/verification/abi.md and independently enumerated in abi.zig.
 * __alignof__ is supported by the pinned Zig/Clang C99 toolchain.
 */
#include <stddef.h>
#include "profile.h"

size_t mz_abi_size(unsigned int type_id)
{
    switch (type_id) {
        case 0: return sizeof(ma_context);
        case 1:
#ifdef MZ_ABI_SIZE_FAULT
            return sizeof(ma_device) + 1;
#else
            return sizeof(ma_device);
#endif
        case 2: return sizeof(ma_device_config);
        case 3: return sizeof(ma_device_id);
        case 4: return sizeof(ma_device_info);
        default: return (size_t)-1;
    }
}

size_t mz_abi_align(unsigned int type_id)
{
    switch (type_id) {
        case 0: return __alignof__(ma_context);
        case 1: return __alignof__(ma_device);
        case 2: return __alignof__(ma_device_config);
        case 3: return __alignof__(ma_device_id);
        case 4: return __alignof__(ma_device_info);
        default: return (size_t)-1;
    }
}

size_t mz_abi_offset(unsigned int field_id)
{
    switch (field_id) {
        case 0: return offsetof(ma_device_config, dataCallback);
        case 1: return offsetof(ma_device_config, notificationCallback);
        case 2: return offsetof(ma_device_config, pUserData);
        case 3: return offsetof(ma_device_config, playback);
        case 4: return offsetof(ma_device_config, capture);
        case 5: return offsetof(ma_device, onData);
        case 6: return offsetof(ma_device, pUserData);
        case 7: return offsetof(ma_device, playback);
        case 8: return offsetof(ma_device, capture);
        case 9: return offsetof(ma_device_info, name);
        case 10: return offsetof(ma_device_info, isDefault);
        case 11: return offsetof(ma_device_info, nativeDataFormats);
        default: return (size_t)-1;
    }
}

int mz_abi_enum(unsigned int value_id)
{
    switch (value_id) {
        case 0: return MA_SUCCESS;
        case 1: return MA_INVALID_ARGS;
        case 2: return ma_format_f32;
        case 3: return ma_device_type_playback;
        case 4: return ma_device_type_capture;
        case 5: return ma_device_type_duplex;
        case 6: return ma_device_type_loopback;
        case 7: return ma_backend_null;
        default: return 2147483647; /* Outside the tested result/enum set. */
    }
}

/* Synthetic callback ABI exercise, not a native-device callback. The device is
 * deliberately NULL; only six borrowed sample slots and frameCount are supplied.
 * Buffers have guard values, so the C side also checks the Zig writes' footprint.
 * NULL callback returns -1; mismatch returns 1; complete agreement returns 0.
 */
int mz_abi_call_callback(ma_device_data_proc callback)
{
    const float input[6] = {1, 2, 3, 4, 5, 6};
    float guarded[8] = {-1234, 0, 0, 0, 0, 0, 0, 5678};
    unsigned int i;
    if (callback == NULL) return -1;
    callback(NULL, &guarded[1], input, 3);
    if (guarded[0] != -1234 || guarded[7] != 5678) return 1;
    for (i = 0; i < 6; ++i) {
        if (guarded[i + 1] != input[i] + 10) return 1;
    }
    return 0;
}
