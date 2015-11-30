#include <stdio.h>
#include "main.h"

int main (int argc, char* args[]) {
    char* w;

    w = unparse(suma(parse("12344"), parse("12345")));
    printf("%s", w);
    
    return 0;
}

void test_parse(){
    bcd* wynik;
    char* wynik2;

    wynik = parse("10");
    wynik2 = unparse(wynik);
    printf("[10]=[%s]\n", wynik2);
   
    wynik = parse("-10");
    wynik2 = unparse(wynik);
    printf("[-10]=[%s]\n", wynik2);

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
}
