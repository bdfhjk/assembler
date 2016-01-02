#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "main.h"

/*
	Print the M2 (result matrix) to stdio as a non-transposed matrix (remove transposition)
*/
void print(){
        int i, j;
        for(i = 0; i < H; i++)
        {
                for(j = 0; j < W; j++)
                {
		     printf("%f ", M2[j * (H + 4) + i]);
                     //printf("0x%X ", *(unsigned int*)&(M2[j * H + i]));
                }
                printf("\n");
        }
	printf("\n");
}

void load(){
        int i, j, szer, wys;
	float *M, waga;
        scanf("%d %d %f", &szer, &wys, &waga);
	M = malloc(szer*(wys+4)*sizeof(float));
        for(i = 0; i < wys; i++)
                for(j = 0; j < szer; j++){
                        scanf("%f", &M[j * (wys + 4) + i]);      //storing matrix in transposed form with 4 float zeros right margin
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
		step(T);
		print();
	}
        return 0;
}
