%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
	extern FILE *yyin;
%}

%token MR COM

%start liste


%%

liste : %empty;

%%
