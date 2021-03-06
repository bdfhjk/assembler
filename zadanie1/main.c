#include <stdio.h>
#include <string.h>
#include "main.h"
#include <math.h>

void test_suma_roznica(){
    int i, j;
    char* w;
    bcd *a, *b, *c;
    int sumaok = 1;
    int roznicaok = 1;

    for(i = -500; i < 500; i++)
        for(j = -500; j < 500; j++){
            char str1[15];
            char str2[15];
            char str3[15];
            sprintf(str1, "%d", i);
            sprintf(str2, "%d", j);
            sprintf(str3, "%d", i+j);

            a = parse(str1);
            b = parse(str2);
            c = suma(a, b);
            w = unparse(c);

            if (strcmp(w, str3) != 0) {
                printf("SUMA ERROR [i = %d | j = %d | %s = %s ]\n", i, j, w, str3);
                sumaok = 0;
            }

            sprintf(str1, "%d", i);
            sprintf(str2, "%d", j);
            sprintf(str3, "%d", i-j);

            a = parse(str1);
            b = parse(str2);
            c = roznica(a, b);
            w = unparse(c);

            if (strcmp(w, str3) != 0){
                printf("ROZNICA ERROR [i = %d | j = %d | %s = %s ]\n", i, j, w, str3);
                roznicaok = 0;
            }
        }

        if (sumaok)
            printf("SUMA \t \t OK\n");
        if (roznicaok)
            printf("ROZNICA \t OK \n");
}

void test_parse_unparse(){
    int i;
    bcd* wynik;
    char liczba1[15];
    char* liczba2;
    int parseok = 1;
    for(i = -150000; i < 150000; i++){
        sprintf(liczba1, "%d", i);
        wynik = parse(liczba1);
        liczba2 = unparse(wynik);

        if (strcmp(liczba1, liczba2) != 0){
            printf("PARSE ERROR [i = %d | %s = %s ]\n", i, liczba1, liczba2);
            parseok = 0;
        }
    }

    if (parseok)
        printf("PARSE \t \t OK\n");
}

void test_shift_left_bcd(){
    long long i, j;
    char* w;
    bcd *a, *b, *c;
    int shiftok = 1;
    
    for(i = -100; i < 100; i++)
        for(j = 0; j < 12; j++){
            char str1[15];
            char str3[15];
            sprintf(str1, "%lld", i);
            sprintf(str3, "%lld", i * (long long)pow(10,j));

            a = parse(str1);
            c = shift_left_bcd(a, j);
            w = unparse(c);

            if (strcmp(w, str3) != 0) {
                printf("SHIFT_LEFT_BCD ERROR [i = %lld | j = %lld | %s = %s ]\n", i, j, w, str3);
                shiftok = 0;
            }
        }

    if (shiftok)
        printf("SHIFT_LEFT \t OK\n");
}

void test_shift_right_bcd(){
    long long i, j;
    char* w;
    bcd *a, *b, *c;
    int shiftok = 1;
    
    for(i = 0; i < 100000; i++)
        for(j = 0; j < 9; j++){
            char str1[15];
            char str3[15];
            sprintf(str1, "%lld", i);
            sprintf(str3, "%lld", i / (long long)pow(10,j));

            a = parse(str1);
            c = shift_right_bcd(a, j);
            w = unparse(c);

            if (strcmp(w, str3) != 0) {
                printf("SHIFT_RIGHT_BCD ERROR [i = %lld | j = %lld | %s = %s ]\n", i, j, w, str3);
                shiftok = 0;
            }
        }

    if (shiftok)
        printf("SHIFT_RIGHT \t OK\n");
}

void test_iloczyn(){
    int i, j;
    char* w;
    bcd *a, *b, *c;
    int iloczynok = 1;
    
    for(i = -1000; i < 1000; i++)
        for(j = -100; j < 100; j++){
            char str1[15];
            char str2[15];
            char str3[15];
            sprintf(str1, "%d", i);
            sprintf(str2, "%d", j);
            sprintf(str3, "%d", i*j);

            a = parse(str1);
            b = parse(str2);
            c = iloczyn(a, b);
            w = unparse(c);

            if (strcmp(w, str3) != 0) {
                printf("ILOCZYN ERROR [i = %d | j = %d | %s = %s ]\n", i, j, w, str3);
                iloczynok = 0;
            }
        }

    if (iloczynok)
        printf("ILOCZYN \t OK\n");
}

void test_iloraz(){
    int i, j;
    char* w;
    bcd *a, *b, *c;
    int ilorazok = 1;
    
    for(i = -500; i < 500; i++)
        for(j = -500; j < 500; j++){
            if (j==0) continue;
            char str1[15];
            char str2[15];
            char str3[15];
            sprintf(str1, "%d", i);
            sprintf(str2, "%d", j);
            sprintf(str3, "%d", i/j);

            a = parse(str1);
            b = parse(str2);
            c = iloraz(a, b);
            w = unparse(c);

            if (strcmp(w, str3) != 0) {
                printf("ILORAZ ERROR [i = %d | j = %d | %s = %s ]\n", i, j, w, str3);
                ilorazok = 0;
            }
        }

    if (ilorazok)
        printf("ILORAZ \t \t OK\n");
}

int main (int argc, char* args[]) {
    test_parse_unparse();
    test_suma_roznica();
    test_shift_left_bcd();
    test_shift_right_bcd();
    test_iloczyn();
    test_iloraz();
    return 0;
}
