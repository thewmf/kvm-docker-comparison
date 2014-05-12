/* -*- mode: C; tab-width: 2; indent-tabs-mode: nil; -*- */


typedef uint64_t u64Int;
typedef int64_t s64Int;

/* Random number generator */
#ifdef LONG_IS_64BITS
#define POLY 0x0000000000000007UL
#define PERIOD 1317624576693539401L
#else
#define POLY 0x0000000000000007ULL
#define PERIOD 1317624576693539401LL
#endif


extern u64Int HPCC_starts (s64Int);
extern u64Int HPCC_starts_LCG (s64Int);

#define LCG_MUL64 6364136223846793005ULL
#define LCG_ADD64 1

extern u64Int *HPCC_Table;

#define FSTR64	"%lu"
#define CPUSEC		GetTime
#define RTSEC		GetTime
