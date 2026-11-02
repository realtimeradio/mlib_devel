#ifndef _TMRCTR_H_
#define _TMRCTR_H_

#include "xparameters.h"

// Number of timer clock cycles per millisecond.
#define TMRCTR_CYCLES_PER_MS (XPAR_TMRCTR_0_CLOCK_FREQ_HZ / 1000)

// Initializes the timer counter.  The 64 bit counter starts from 0, unless
// JAM_TMRCTR_START is defined, in which case it starts from that value.  This
// allows testing of timer rollover behavior without waiting weeks.  For
// example, with a 100 MHz clock, these values are one minute before the
// rollover of ms_tmrctr() and tick_tmrctr() respectively:
//
//   make CFLAGS=-DJAM_TMRCTR_START=0x1869E9A5F4400ULL
//   make CFLAGS=-DJAM_TMRCTR_START=0x7FFE9A5F4400ULL
void init_tmrctr();

// Returns 64 bit clock cycle counter value.
// With 100 MHz clock, these are in 10 ns units.
u64 read_tmrctr();

// Returns bits [46:15] of the 64 bit clock cycle counter value.  With 100 MHz
// clock, the tick interval is 327.68 microseconds and tick values will roll
// approximately every 16.25 days.  Note that every 3 ticks is approximatelty 1
// ms (983.04 usec).
u32 tick_tmrctr();

// Returns milliseconds since the timer was started.  This rolls over at 2^32
// (approximately every 49.7 days), as required by LwIP's sys_now().  This
// uses a 64 bit division, so prefer read_tmrctr() in tight loops.
u32 ms_tmrctr();

void dump_tmrctr();

#endif // _TMRCTR_H_
