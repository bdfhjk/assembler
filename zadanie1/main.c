#include <stdio.h>
#include <string.h>
#include "main.h"

void test_suma_roznica(){
    int i, j;
    char* w;
    bcd *a, *b, *c;
    int sumaok = 1;
    int roznicaok = 1;

    for(i = -1500; i < 1500; i++)
        for(j = -1500; j < 1500; j++)
        {
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
            printf("SUMA OK\n");
        if (roznicaok)
            printf("ROZNICA OK\n");
}

void test_parse_unparse(){
    int i;
    bcd* wynik;
    char liczba1[15];
    char* liczba2;
    int parseok = 1;
    for(i = -15000000; i < 15000000; i++){
        sprintf(liczba1, "%d", i);
        wynik = parse(liczba1);
        liczba2 = unparse(wynik);
        
        if (strcmp(liczba1, liczba2) != 0){
            printf("PARSE ERROR [i = %d | %s = %s ]\n", i, liczba1, liczba2);
            parseok = 0;
        }
    }
    
    if (parseok)
        printf("PARSE OK\n");
}

int main (int argc, char* args[]) {

    test_parse_unparse();
    test_suma_roznica();    
    return 0;
}
