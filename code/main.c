#include "../inc/code_proj.tab.h"
#include <stdio.h>
extern int yylex();

int main() {
	printf("main\n");
	int r;
	r = yyparse();
	printf("r : %d\n",r);
	//yyerror("err");
}