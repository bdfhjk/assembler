#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int W, H;                      //width and height
float E;                        //weight
float *M1, *M2;           //base and result matrix

int n;                          //number of steps
float *N;                   //matrix of steps

void load(){
        int i, j;
        scanf("%d %d %f", &W, &H, &E);
        posix_memalign((void**)&M1, 16, W*H*sizeof(float));
        posix_memalign((void**)&M2, 16, W*H*sizeof(float));
        for(i = 0; i < H; i++)
                for(j = 0; j < W; j++){
                        scanf("%f", &M1[j * H + i]);  //storing matrix in transposed form
                        M2[j * H + i] = M1[j * H + i];    //initially the result matrix is equal base matrix
                }
        scanf("%d", &n);
        posix_memalign((void**)&N, 16, n*H*sizeof(float));
        for(i = 0; i < n; i++)
                for(j = 0; j < H; j++)
                        scanf("%f", &N[i * H + j]);
}

void print(){
        int i, j;
        for(i = 0; i < H; i++){
                for(j = 0; j < W; j++)
                        printf("%f ", M2[j * H + i]);
                printf("\n");
        }
	
	printf("\n");
}

void start_c(){
}

void step_c(float T[]){
	int i, j;

	for(i=0; i < H; i++)
		M1[0*H + i] = T[i];

	for(i=1; i < W; i++)
		for(j=0; j < H; j++){
			M1[i *H + j] += E * M2[(i-1)*H +j];
			if (j > 0) {
				M1[i*H + j] += E * M2[(i-1)*H + (j-1)];
				M1[i*H + j] += E * M2[i*H + (j-1)];
			}
			if (j < H-1) {
				M1[i*H + j] += E * M2[(i-1)*H + (j+1)];
				M1[i*H + j] += E * M2[i*H + (j+1)];
			}
		}
	
	float *_T = M1;
	M1 = M2;
	M2 = _T;
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