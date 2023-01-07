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

	char data[1024];		// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char ids[512][64];		// Tableau des identificateurs
	int id_count = 0;		// Nombre d'identificateurs
	int reg_count = 1;		// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;		// Nombre d'affectations executées
	extern char * last_id;  // Nom du dernier id rencontré
	extern int in_func; 	// Bool pour savoir si on est dans une fonction 
	int set = 0;			// Bool pour la mise en place du label de fonction
%}

%union {
	char *id;
	int entier;
}

%token <id> ID
%token <entier> NB 
%token EG 
%token PL
%token MN
%token FX
%token DV
%token OP
%token CP
%token OB
%token CB
%token SC
%token LOCAL
%token DLR
%token EXPR

// Regles de grammaire
%left PL MN
%left FX DV

%%
programme : %empty {printf("in liste_instruction empty\n");}
		  | instruction SC programme {printf("in liste_instruction sc prog\n");}

;

instruction : ID EG somme_e {	// Affectation
		if (in_func){
			yyerror("Déclaration d'un id global dans une fonction.\n");
		}
		if (find_entry($1) == -1)
			add_tds($1, ENT, 1, 0, 1, "");
	    findStr($1,ids);
		strcat(instructions, "sw $t");
		strcat(instructions, itoa(reg_count-1));
		strcat(instructions, ", ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
		reg_count = 1;
		li_count = 0;
	    }
		| decl_fonc 
		| appel_fonc 
;

concat : concat operande
	   | operande
;

liste_operande : liste_operande operande 
			   | operande 
			   | DLR OB ID CB 			   
;

operande : DLR OP EXPR somme_e CP 
		 | DLR OP appel_fonc CP 
;

somme_e : unique
     | somme_e PL somme_e {operation("add");}
     | somme_e MN somme_e {operation("sub");}
     | somme_e FX somme_e {operation("mul");}
     | somme_e DV somme_e {operation("div");}
     | OP somme_e CP 
     | MN somme_e %prec MN {
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

unique : ID {
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
       | NB {
    li_count++;
	strcat(instructions,"li $t");
	strcat(instructions,itoa(reg_count));
	strcat(instructions,", ");
	strcat(instructions,itoa($1));
	strcat(instructions,"\n");
	reg_count++;
	}
;

decl_fonc : ID OP CP OB decl_loc programme CB {
		if (find_entry($1) != -1)
			yyerror("ID de la fonction déjà dans la tds.\n");
		add_tds($1, FCT, 1, 0, 1, "");
		strcat(instructions, "jr $ra\n\n");
		set = 0;
		in_func = 0;
		printf("in decl fonc\n");
	}
;

decl_loc : %empty { 
		//on print le label de la fonction courante (récupéré avec lex)
		if (in_func && !set){
			strcat(instructions, last_id);
			strcat(instructions, ":\t");
			set = 1;
		} else {
			yyerror("Declaration de locale hors fonction.\n");
		}
		printf("end decl loc : last_id %s\n", last_id);
}
		 | decl_loc LOCAL ID EG concat SC {
		if (in_func && !set){
			strcat(instructions, last_id);
			strcat(instructions, ":\t");
			set = 1;
		}
		if (find_entry($3) != -1)
			yyerror("ID de la variable locale déjà dans la tds.\n");
		add_tds($3, CH, 1, 0, 0, last_id);
		printf("in decl loc\n");
	}
;

appel_fonc : ID {
	if (!in_func && strcmp(get_fonc($1), "") == 0 && get_type($1) == FCT){
	//Génération mips appel de la fonction
		printf("appel fonction\n");
		strcat(instructions, "jal ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
	} else {
		printf("appel fonction pas bon : in_func %i, get_fonc = %s,"
		" type = %s\n", in_func, get_fonc($1), (get_type($1) == FCT ? "FCT":
		 "autre"));
	}
}
		   | ID liste_operande {
	if (!in_func && strcmp(get_fonc($1), "") != 0 && get_type($1) == FCT){
	//Génération mips appel de la fonction avec argument(s)
	//manque load arguments dans $a 
		strcat(instructions, "jal ");
		strcat(instructions, $1);
		strcat(instructions, "\n");
	}
}


%%
// Fonction qui execute une operation entre les deux derniers registres temporaires utilisés
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

char* itoa(int x) {
    static char str[100];
    sprintf(str, "%d", x);
    return str;
}

int yyerror(char *s) {
  fprintf(stderr, "Erreur de syntaxe : %s\n", s);
  return 1;
}
