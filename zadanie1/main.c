#include <stdio.h>
#include "main.h"

int main (int argc, char* args[]) {
    
    bcd* wynik;
    char* wynik2;

    wynik = parse("1");
    wynik2 = unparse(wynik);
    printf("[1]=[%s]\n", wynik2);
   
    wynik = parse("-1");
    wynik2 = unparse(wynik);
    printf("[-1]=[%s]\n", wynik2);

    wynik = parse("123");
    wynik2 = unparse(wynik);
    printf("[123]=[%s]\n", wynik2);

    wynik = parse("-123");
    wynik2 = unparse(wynik);
    printf("[-123]=[%s]\n", wynik2);

    wynik = parse("123456789123456789123456789");
    wynik2 = unparse(wynik);
    printf("[123456789123456789123456789]=[%s]\n", wynik2);

    wynik = parse("-123456789123456789123456789");
    wynik2 = unparse(wynik);
    printf("[-123456789123456789123456789]=[%s]\n", wynik2);
	
   return 0;
}
