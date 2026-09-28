/* One low-level profile for C compilation and Zig translation. Device I/O, PCM
 * conversion, resampling and buffers remain upstream-owned. File codecs and the
 * high-level asset/graph/engine layer are deliberately outside this package API. */
#ifndef JCR_MINIAUDIO_PROFILE_H
#define JCR_MINIAUDIO_PROFILE_H
#define MA_NO_DECODING
#define MA_NO_ENCODING
#define MA_NO_RESOURCE_MANAGER
#define MA_NO_NODE_GRAPH
#define MA_NO_ENGINE
#include "miniaudio.h"
#endif
