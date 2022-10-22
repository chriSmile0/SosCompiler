#include "../inc/code_proj.tab.h"
#include <stdio.h>
extern int yylex();

int main() {
	printf("test\n");
	int r;
	r = yyparse();
	printf("r : %d\n",r);
}