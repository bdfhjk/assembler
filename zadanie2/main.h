extern int W;				//matrix width
extern int H;				//matrix height
extern float E;			//weight
extern float *M1;			//base matrix
extern float *M2;			//result matrix
extern int n;				//number of simulation steps
extern float *N;			//matrix with simulation steps

extern void start(int szer, int wys, float* M, double waga);
extern void step(void *T);
