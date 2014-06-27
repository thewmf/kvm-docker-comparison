/* -*- mode: C; tab-width: 2; indent-tabs-mode: nil; -*- */

// Heavily modified by rajamony

/*
 * This code has been contributed by the DARPA HPCS program.  Contact
 * David Koester <dkoester@mitre.org> or Bob Lucas <rflucas@isi.edu>
 * if you have questions.
 *
 * GUPS (Giga UPdates per Second) is a measurement that profiles the memory
 * architecture of a system and is a measure of performance similar to MFLOPS.
 * The HPCS HPCchallenge RandomAccess benchmark is intended to exercise the
 * GUPS capability of a system, much like the LINPACK benchmark is intended to
 * exercise the MFLOPS capability of a computer.  In each case, we would
 * expect these benchmarks to achieve close to the "peak" capability of the
 * memory system. The extent of the similarities between RandomAccess and
 * LINPACK are limited to both benchmarks attempting to calculate a peak system
 * capability.
 *
 * GUPS is calculated by identifying the number of memory locations that can be
 * randomly updated in one second, divided by 1 billion (1e9). The term "randomly"
 * means that there is little relationship between one address to be updated and
 * the next, except that they occur in the space of one half the total system
 * memory.  An update is a read-modify-write operation on a table of 64-bit words.
 * An address is generated, the value at that address read from memory, modified
 * by an integer operation (add, and, or, xor) with a literal value, and that
 * new value is written back to memory.
 *
 * We are interested in knowing the GUPS performance of both entire systems and
 * system subcomponents --- e.g., the GUPS rating of a distributed memory
 * multiprocessor the GUPS rating of an SMP node, and the GUPS rating of a
 * single processor.  While there is typically a scaling of FLOPS with processor
 * count, a similar phenomenon may not always occur for GUPS.
 *
 * For additional information on the GUPS metric, the HPCchallenge RandomAccess
 * Benchmark,and the rules to run RandomAccess or modify it to optimize
 * performance -- see http://icl.cs.utk.edu/hpcc/
 *
 */

/*
 * This file contains the computational core of the single cpu version
 * of GUPS.  The inner loop should easily be vectorized by compilers
 * with such support.
 *
 * This core is used by both the single_cpu and star_single_cpu tests.
 */

#include <float.h>
#include <limits.h>
#include <stdint.h>
#include "utils.h"
#include "RandomAccess.h"


/* -*- mode: C; tab-width: 2; indent-tabs-mode: nil; -*-
 *
 * This file provides utility functions for the RandomAccess benchmark suite.
 */

/* Utility routine to start random number generator at Nth step */
u64Int
HPCC_starts(s64Int n)
{
  int i, j;
  u64Int m2[64];
  u64Int temp, ran;

  while (n < 0) n += PERIOD;
  while (n > PERIOD) n -= PERIOD;
  if (n == 0) return 0x1;

  temp = 0x1;
  for (i=0; i<64; i++) {
    m2[i] = temp;
    temp = (temp << 1) ^ ((s64Int) temp < 0 ? POLY : 0);
    temp = (temp << 1) ^ ((s64Int) temp < 0 ? POLY : 0);
  }

  for (i=62; i>=0; i--)
    if ((n >> i) & 1)
      break;

  ran = 0x2;
  while (i > 0) {
    temp = 0;
    for (j=0; j<64; j++)
      if ((ran >> j) & 1)
        temp ^= m2[j];
    ran = temp;
    i -= 1;
    if ((n >> i) & 1)
      ran = (ran << 1) ^ ((s64Int) ran < 0 ? POLY : 0);
  }

  return ran;
}

/* Utility routine to start LCG random number generator at Nth step */
u64Int
HPCC_starts_LCG(s64Int n)
{
  u64Int mul_k, add_k, ran, un;

  mul_k = LCG_MUL64;
  add_k = LCG_ADD64;

  ran = 1;
  for (un = (u64Int)n; un; un >>= 1) {
    if (un & 1)
      ran = mul_k * ran + add_k;
    add_k *= (mul_k + 1);
    mul_k *= mul_k;
  }

  return ran;
}


/* Number of updates to table (suggested: 4x number of table entries) */
// #define NUPDATE (4 * TableSize)
#define NUPDATE (100ULL*10000000)

static void
RandomAccessUpdate(u64Int TableSize, u64Int *Table) {
  u64Int i;
  u64Int ran[128];              /* Current random numbers */
  int j;

  /* Perform updates to main table.  The scalar equivalent is:
   *
   *     u64Int ran;
   *     ran = 1;
   *     for (i=0; i<NUPDATE; i++) {
   *       ran = (ran << 1) ^ (((s64Int) ran < 0) ? POLY : 0);
   *       table[ran & (TableSize-1)] ^= ran;
   *     }
   */
  for (j=0; j<128; j++)
    ran[j] = HPCC_starts ((NUPDATE/128) * j);

  for (i=0; i<NUPDATE/128; i++) {
#ifdef _OPENMP
#pragma omp parallel for
#endif
    for (j=0; j<128; j++) {
      ran[j] = (ran[j] << 1) ^ ((s64Int) ran[j] < 0 ? POLY : 0);
      Table[ran[j] & (TableSize-1)] ^= ran[j];
    }
  }
}


int
HPCC_RandomAccess(HPCC_Params *params, int doIO, double *GUPs, int *failure) {
  u64Int i;
  u64Int temp;
  double cputime;               /* CPU time to update table */
  double realtime;              /* Real time to update table */
  double totalMem;
  u64Int *Table;
  u64Int logTableSize, TableSize;
  FILE *outFile = NULL;

  if (doIO) {
    // outFile = fopen( params->outFname, "w+" );
    outFile = stdout;
    if (! outFile) {
      outFile = stderr;
      fprintf( outFile, "Cannot open output file.\n" );
      return 1;
    }
  }
  fprintf (outFile, "Generated on %s\n", params->nowASCII);
  fflush (outFile);

  /* calculate local memory per node for the update table */
  totalMem = params->HPLMaxProcMem;
  totalMem = 4294967296ULL * 2 * sizeof(u64Int);		// OVERRIDING TO BE CONSTANT

  totalMem /= sizeof(u64Int);

  /* calculate the size of update array (must be a power of 2) */
  for (totalMem *= 0.5, logTableSize = 0, TableSize = 1;
       totalMem >= 1.0;
       totalMem *= 0.5, logTableSize++, TableSize <<= 1)
    ; /* EMPTY */

  Table = HPCC_XMALLOC( u64Int, TableSize );

  if (! Table) {
    if (doIO) {
      fprintf( outFile, "Failed to allocate memory for the update table (" FSTR64 ").\n", TableSize);
      fclose( outFile );
    }
    return 1;
  }
  // params->RandomAccess_N = (s64Int)TableSize;

  /* Print parameters for run */
  if (doIO) {
  fprintf( outFile, "Main table size   = 2^" FSTR64 " = " FSTR64 " words\n", logTableSize,TableSize);
  fprintf( outFile, "Number of updates = " FSTR64 "\n", (u64Int) NUPDATE);
  fflush (outFile);
  }

  /* Initialize main table */
  for (i=0; i<TableSize; i++) Table[i] = i;

  /* Begin timing here */
  cputime = -CPUSEC();
  realtime = -RTSEC();

  RandomAccessUpdate( TableSize, Table );

  /* End timed section */
  cputime += CPUSEC();
  realtime += RTSEC();

  /* make sure no division by zero */
  *GUPs = (realtime > 0.0 ? 1.0 / realtime : -1.0);
  *GUPs *= 1e-9*NUPDATE;
  /* Print timing results */
  if (doIO) {
  fprintf( outFile, "CPU time used  = %.6f seconds\n", cputime);
  fprintf( outFile, "Real time used = %.6f seconds\n", realtime);
  fprintf( outFile, "%.9f Billion(10^9) Updates    per second [GUP/s]\n", *GUPs );
  fflush (outFile);
  }
#if PERCS_SANITY_CHECK_RUN_NO_VERIFY		// Significantly speed up run by not verifying. Run is NON-CONFORMANT but fails
{double x = ((double) TableSize) * 0.1, y = pow (10, ceil (log10 (x))); temp = (s64Int) y; }
#else
  /* Verification of results (in serial or "safe" mode; optional) */
  temp = 0x1;
  for (i=0; i<NUPDATE; i++) {
    temp = (temp << 1) ^ (((s64Int) temp < 0) ? POLY : 0);
    Table[temp & (TableSize-1)] ^= temp;
  }

  temp = 0;
  for (i=0; i<TableSize; i++)
    if (Table[i] != i)
      temp++;
#endif
  if (doIO) {
  fprintf( outFile, "Found " FSTR64 " errors in " FSTR64 " locations (%s).\n",
           temp, TableSize, (temp <= 0.01*TableSize) ? "passed" : "failed");
  }
  if (temp <= 0.01*TableSize) *failure = 0;
  else *failure = 1;

#if HPCC_RA_PERCS
  XFREE_GLOBAL (Table);
#else
  HPCC_free( Table );
#endif
  if (doIO) {
    fflush( outFile );
    fclose( outFile );
  }

  return 0;
}


int 
main () {
	HPCC_Params *params = initialize();
	double GUPs;
	int failure;

	HPCC_RandomAccess (params, 1, &GUPs, &failure);
	return 0;
}
