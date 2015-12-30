#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "main.h"

/*
	Print the M2 (result matrix) to stdio as a non-transposed matrix (remove transposition)
*/
void print(){
        int i, j;
        for(i = 0; i < H; i++){
                for(j = 0; j < W; j++)
                        printf("%f ", M2[j * H + i]);
                printf("\n");
        }
	printf("\n");
}

/*
	C equivalent of start procedure
*/
void start_c(int szer, int wys, float* M, float waga){
	W = szer;
	H = wys;
	E = waga;

	posix_memalign((void**)&M2, 16, (W*H + 4)*sizeof(float));
	posix_memalign((void**)&M1, 16, (W*H + 4)*sizeof(float));
	
	memcpy(M1, M, (W*H + 4)*sizeof(float));
	memcpy(M2, M, (W*H + 4)*sizeof(float));
}

void step_c(float T[]){
	int i, j;

	for(i=0; i < H; i++)
		M1[0*H + i] = T[i];

	for(i=1; i < W; i++)
		for(j=0; j < H; j++){
			M1[i *H + j] += E * (M2[i*H + j] - M2[(i-1)*H +j]);
			if (j > 0) {
				M1[i*H + j] += E * (M2[i*H + j] - M2[(i-1)*H + (j-1)]);
				M1[i*H + j] += E * (M2[i*H + j] - M2[i*H + (j-1)]);
			}
			if (j < H-1) {
				M1[i*H + j] += E * (M2[i*H + j] - M2[(i-1)*H + (j+1)]);
				M1[i*H + j] += E * (M2[i*H + j] - M2[i*H + (j+1)]);
			}
		}
	
	float *_T = M1;
	M1 = M2;
	M2 = _T;
}

void load(){
        int i, j, szer, wys;
	float *M, waga;
        scanf("%d %d %f", &szer, &wys, &waga);
	M = malloc(szer*wys*sizeof(float));
        for(i = 0; i < wys; i++)
                for(j = 0; j < szer; j++){
                        scanf("%f", &M[j * wys + i]);      //storing matrix in transposed form
                }

        scanf("%d", &n);
        posix_memalign((void**)&N, 16, n*wys*sizeof(float));
        for(i = 0; i < n; i++)
                for(j = 0; j < wys; j++)
                        scanf("%f", &N[i * wys + j]);
	
	start(szer, wys, M, waga);
}

int main(int argc, char* args[]){	
	int i;
	float *T;
	load();
	print();
	T = malloc(H * sizeof(float));
	for(i = 0; i < n; i++){
		memcpy(T, N + i*H, H * sizeof(float)); 
		step_c(T);
		print();
	}
        return 0;
}