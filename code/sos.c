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
	while ((t = yylex()) != 0);
	printf("--- data:\n%s\n", data);
	printf("---instructions:\n%s\n", instructions);
	return 0;
}
