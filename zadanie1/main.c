#include <stdio.h>
#include "main.h"







void test_suma_a(){
    int i, j;
    char* w;
    bcd *a, *b, *c;
    
    for(i = 0; i < 5000; i++)
        for(j = 0; j < 5000; j++)
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
            
            if (strcmp(w, str3) != 0)
                printf("ERROR [i = %d | j = %d | %s = %s\n ]", i, j, w, str3);
            else if(i+j % 1000 == 0)
                printf("OK! :-)\n");
        }
}


void test_suma(){
    char* w;
    bcd *a, *b, *c;

    a = parse("101");
    b = parse("99");
    c = suma(a, b);
    w = unparse(c);

    printf("[200 = %s]\n", w);

    /*
    a = parse("1111111111");
    b = parse("2");
    c = suma(a, b);
    w = unparse(c);

    printf("[1111111113 = %s]\n", w);
    
    a = parse("99999");
    b = parse("99999");
    c = suma(a, b);
    w = unparse(c);

    printf("[199998= %s]\n", w);
    
    
    a = parse("123");
    b = parse("234");
    c = suma(a, b);
    w = unparse(c);

    printf("[357 = %s]\n", w);
	
    
    a = parse("99");
    b = parse("99");
    c = suma(a, b);
    w = unparse(c);

    printf("[198 = %s]\n", w);
/*	
    a = parse("1");
    b = parse("0");
    c = suma(a, b);
    w = unparse(c);

    printf("[1 = %s]\n", w);
 
    a = parse("0");
    b = parse("1");
    c = suma(a, b);
    w = unparse(c);

    printf("[1 = %s]\n", w);
*/
}


int main (int argc, char* args[]) {
    
    test_suma_a();
    return 0;
}

void test_parse(){
    bcd* wynik;
    char* wynik2;
    
    wynik = parse("0");
    wynik2 = unparse(wynik);
    printf("[0]=[%s]\n", wynik2);

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
