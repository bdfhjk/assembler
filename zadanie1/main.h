typedef char bcd;
extern bcd* parse(char*);
extern char* unparse(bcd*);
extern bcd* suma(bcd*, bcd*);
extern bcd* roznica(bcd*, bcd*);
extern bcd* iloczyn(bcd*, bcd*);
extern bcd* iloraz(bcd*, bcd*);
extern bcd* shift_left_bcd(bcd*, long long);
extern bcd* shift_right_bcd(bcd*, long long);