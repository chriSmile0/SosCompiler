#include "../inc/code_proj.tab.h"
#include <stdio.h>
extern int yylex();

int main() {
	printf("main\n");
	int t;
	while ((t = yylex()) != 0) 
		printf("t : %d\n",t);
}