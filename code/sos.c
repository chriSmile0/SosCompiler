#include "../inc/code_proj.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
extern int yylex();
extern char data[1024];
extern char instructions[4096];

int main(int argc, char **argv)
{
	strcat(data, "\t.data\n");
	strcat(instructions, "\t.text\n__start:\n");
	int t;
	yyparse();
	printf("%s%s\n", data, instructions);
	return 0;
}
