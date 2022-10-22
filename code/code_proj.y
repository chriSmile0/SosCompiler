%{
	#include <stdio.h>
	extern int yylex();
	extern void yyerror(const char *msg);
%}

%start liste

%%

liste : %empty;

%%
