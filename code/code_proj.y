%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	extern FILE *yyin;
%}

%token MR
%token CC
%start liste


%%

liste : %empty;

%%
