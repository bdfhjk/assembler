#include <stdio.h>
#include "main.h"

int main (int argc, char* args[]) {
    int wynik = parse("-123123");
    printf("Wynik=%d\n", wynik);
    return wynik;
}
