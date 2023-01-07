%{
	#include <stdio.h>
	#include <string.h>
	#include "fct_yacc.h"
	extern int yylex();
	int yyerror(char *s);
	extern FILE *yyin;

	void operation(char *str);
	void findStr(char *str, char strs[512][64]);
	char* itoa(int x);
	void genElse();
	void genFi();
	void genWhile();

	char data[1024];			// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char ids[512][64];		// Tableau des identificateurs
	int id_count = 0;		// Nombre d'identificateurs
	int reg_count = 1;		// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;		// Nombre d'affectations executées
	int pileWhile[512];		// Pile des while
	int i_while = 0;		// Indice de la pile des while
	int pileElse[512];		// Pile des else
	int if_count = 0;		// Indice de la pile des else utilisé pour Else
	int fi_count = 0;		// Indice de la pile des else utilisé pour Fi
	int else_count = 0;		// Prochaine valeur entiere à coller au prochaine label else (ex : "Else4:")
	int while_count = 0;		// Prochaine valeur entiere à coller au prochaine label while (ex : "While4:")
	// Check .lex
	extern int elsee;
	extern int whilee;
	extern int until;

%}

%token <id> ID
%token <entier> NB
%token EG
%token PL
%token MN
%token FX
%token DV
%token OP
%token CP
%token END

%token IF
%token THEN
%token FI
%token ELSE
%token WHL
%token DO
%token DONE
%token UTL
%token DEC
%token OB
%token CB

// Regles de grammaire
%left PL MN
%left FX DV

%union {
	char *id;
	int entier;
}

%%
programme : instruction END programme 
	  | instruction END 
	  {
	  	if (elsee) { // Si l'instruction sur laquelle on est est un else, alors on est dans une instruction de type IF ... THEN ... ELSE ... FI
			// Il faut donc un label Fi pour sortir une fois la condition réussie
			strcat(instructions, "j Fi");
			strcat(instructions, itoa(pileElse[fi_count-1]));
			strcat(instructions, "\n");
			genElse("Else");
			elsee--;
		}
	  }
;

instruction : ID EG oper	// Affectation
	    {
		if (find_entry($1) == -1)
			add_tds($1, ENT, 1, 0, 0, 1, "");
	    	findStr($1,ids);
		strcat(instructions, "sw $t");
		strcat(instructions, itoa(reg_count-1));
		strcat(instructions, ", ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
		reg_count = 1;
		li_count = 0;
	    }
		| DEC ID OB NB CB { // Déclaration de tableau
			if (find_entry($2) == -1)
				add_tds($2, TAB, 1, $4, -1, 1, "");

			// Buffer contenant la ligne à intégrer dans ".data" du MIPS
			char buff[64];
			size_t max_length = sizeof(buff);
			int ret = snprintf(buff, max_length, "%s:\t.space\t%d\n", $2, $4);

			if (ret >= max_length)
				fprintf(stderr, "|ERREUR| Dépassement du buffer - Dec tab");

			strcat(data, buff);
		}
	    | IF bool THEN programme FI
	    {
	    	genElse();
	    }
	    | IF bool THEN programme ELSE programme FI
	    {
	    	genFi();
	    }
	    | WHL bool DO programme DONE
	    {
		genWhile();
	    	genElse();
	    }
	    | UTL bool DO programme DONE
	    {
		genWhile();
	    	genElse();
	    }
;

bool : NB 
     {
	if (whilee) { // Si l'instruction sur laquelle on est est un while, alors on est dans une instruction de type WHILE ... DO ... DONE
		// Il faut donc un label While pour y retourner
		strcat(instructions, "While");
		strcat(instructions, itoa(while_count));
		strcat(instructions, ":\n");
		pileWhile[i_while] = while_count;
		whilee--;
		while_count++;
		i_while++;
		fi_count--;
	}
	if (until) { // Si l'instruction sur laquelle on est est un until, alors on doit sortir uniquement si la condition réussit
		strcat(instructions, "li $t0, ");
		strcat(instructions, itoa($1));
		strcat(instructions, "\nli $t1, ");
		strcat(instructions, itoa(1));
		strcat(instructions, "\nbeq $t0, $t1, Else");
		strcat(instructions, itoa(else_count));
		strcat(instructions, "\n");
		until--;
		pileElse[if_count] = else_count;
		else_count++;
		if_count++;
		fi_count++;
	} else { // Sinon, on doit sortir uniquement si la condition échoue
		strcat(instructions, "li $t0, ");
		strcat(instructions, itoa($1));
		strcat(instructions, "\n");
		strcat(instructions, "beq $t0, $zero, Else");
		strcat(instructions, itoa(else_count));
		strcat(instructions, "\n");
		pileElse[if_count] = else_count;
		else_count++;
		if_count++;
		fi_count++;
	}
     }
;

oper : unique
     | oper PL oper {operation("add");}
     | oper MN oper {operation("sub");}
     | oper FX oper {operation("mul");}
     | oper DV oper {operation("div");}
     | OP oper CP 
     | MN oper %prec MN
     {
	strcat(instructions, "li $t");
	strcat(instructions, itoa(reg_count));
	strcat(instructions, ", -1\n");
     	strcat(instructions, "mul $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count));
	strcat(instructions, "\n");
     }
;

unique : ID
	{
		li_count++;
		if (find_entry($1) == -1)
			yyerror("ID pas dans la table des symoles");
		strcat(instructions,"lw $t");
		strcat(instructions,itoa(reg_count));
		strcat(instructions,", ");
		strcat(instructions,$1);
		strcat(instructions,"\n");
		reg_count++;
	}
	| NB
	{
		li_count++;
		strcat(instructions,"li $t");
		strcat(instructions,itoa(reg_count));
		strcat(instructions,", ");
		strcat(instructions,itoa($1));
		strcat(instructions,"\n");
		reg_count++;
	}
;


%%
// Fonction qui execute une operation entre les deux derniers registres
// temporaires utilisés
void operation(char *str) {
	strcat(instructions, str);
	strcat(instructions, " $t");
	if (li_count <= 2)
		strcat(instructions,"0");
	else
		strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-2));
	strcat(instructions, ", $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, "\n");
	reg_count--;
	if (li_count <= 2)
		reg_count--;
	li_count--;
	if (reg_count <= 0)
		reg_count = 1;
}

// Fonction qui cherche si un ID est déjà déclaré, sinon il le fait
void findStr (char *str, char strs[512][64]) {
	for (int i = 0; i < id_count; i++) {
		if (strcmp(str, strs[i]) == 0) {
			return;
		}
	}
	strcpy(strs[id_count], str);
	strcat(data, str);
	strcat(data, ":\t.word\t0\n");
	id_count++;
}

void genElse() {
	strcat(instructions, "Else");
	strcat(instructions, itoa(pileElse[--if_count]));
	strcat(instructions, ":\n");
}

void genFi() {
	strcat(instructions, "Fi");
	strcat(instructions, itoa(pileElse[--fi_count]));
	strcat(instructions, ":\n");
}

void genWhile() {
	strcat(instructions, "j While");
	strcat(instructions, itoa(pileWhile[--i_while]));
	strcat(instructions, "\n");
}

char* itoa(int x) {
	static char str[100];
	sprintf(str, "%d", x);
	return str;
}

int yyerror(char *s) {
	fprintf(stderr, "Erreur de syntaxe : %s\n", s);
	return 1;
}
