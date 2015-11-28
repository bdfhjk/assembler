#include <stdio.h>
#include "main.h"

int main (int argc, char* args[]) {
    bcd* wynik = parse("123");
    char* wynik2 = unparse(wynik);
    printf("Wynik=%s\n", wynik2);
    return 0;
}
