#include <stdio.h>
#include <stdlib.h>

int W, H;                      //width and height
float E;                        //weight
float *M1, *M2;        //base and result matrix

int n;                          //number of steps
float *N;                   //matrix of steps

void load(){
        int i, j;
        scanf("%d %d %d %f", &n, &W, &H, &E);
        posix_memalign((void**)&M1, 16, W*H*sizeof(float));
        posix_memalign((void**)&M2, 16, W*H*sizeof(float));
        posix_memalign((void**)&N, 16, n*H*sizeof(float));
        for(i = 0; i < H; i++)
                for(j = 0; j < W; j++){
                        scanf("%f", &M1[j * H + i]);  //storing matrix in transposed form
                        M2[j * H + i] = M1[j * H + i];    //initially the result matrix is equal base matrix
                }
        
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
}

void start_c(){
}

void step_c(){
}

int main(int argc, char* args[]){	
	load();
        print();
        return 0;
}