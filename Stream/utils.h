#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>


typedef struct _HPCC_Params {
	char nowASCII[128];
	char *outFname;
	uint64_t HPLMaxProcMem;
	int StreamThreads;

} HPCC_Params;

/* The legacy of HPCC. A rotten way to define an allocator */

void * mmap_malloc (size_t n);

#define HPCC_XMALLOC(t,s) ((t*)mmap_malloc(sizeof(t)*(s)))
#define HPCC_free(p)	free(p)

#define    Mabs( a_ )          ( ( (a_) <   0  ) ? -(a_) : (a_) )
#define    Mmin( a_, b_ )      ( ( (a_) < (b_) ) ?  (a_) : (b_) )
#define    Mmax( a_, b_ )      ( ( (a_) > (b_) ) ?  (a_) : (b_) )

#define    Mfloor(a,b) (((a)>0) ? (((a)/(b))) : (-(((-(a))+(b)-1)/(b))))
#define    Mceil(a,b)           ( ( (a)+(b)-1 ) / (b) )
#define    Miceil(a,b) (((a)>0) ? ((((a)+(b)-1)/(b))) : (-((-(a))/(b))))

uint64_t		HPCC_LocalVectorSize (void *unused, int num, int size, int dummy);
HPCC_Params	* initialize ();
double	GetTime ();

