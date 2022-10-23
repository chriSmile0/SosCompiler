#include "../inc/code_proj.tab.h"
#include <stdio.h>
extern int yylex();

int main() {
	printf("main\n");

	int t;
	t = yylex();
	while(t != 0) {
		printf("t : %d\n",t);
		t = yylex();
	}

	/*int r;
	r = yyparse();
	printf("r : %d\n",r);*/
	//yyerror("err");
}