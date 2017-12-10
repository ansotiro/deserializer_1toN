#include <stdio.h>
#include <stdlib.h>

#define INTERVALS 16
#define SIZE 16         // Size of dataset
#define N 2             // Number of outputs
#define R 4             // Reorder lever (N*R=NPIPES)


int main(int argc,char *argv[])
{
	int i, j, k, z;
	int A[N*R][INTERVALS*SIZE];

	z=1;
	for (k=0; k<INTERVALS; k++)
		for (j=0; j<N*R; j++)
			for (i=0; i<SIZE; i++)
				A[j][i+k*SIZE] = z++;


	for (j=0; j<INTERVALS*SIZE; j++)
		for (i=0; i<R; i++)
			printf("%d,%d: \t D0: \t %d \t\t\t\tD1: \t %d \n",i, j, A[i][j], A[i+R][j] );


    return 0;
}
