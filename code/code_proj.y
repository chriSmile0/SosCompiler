%{
	#include <stdio.h>
	#include <string.h>
	#include "fct_yacc.h"
	extern int yylex();
	int yyerror(char *s);
	extern FILE *yyin;

	void operation(char *str);
	int findStr(char *str, char strs[512][64], int crea);
	char* itoa(int x);

	char data[1024];			// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char ids[512][64];		// Tableau des identificateurs
	int id_count = 0;		// Nombre d'identificateurs
	int reg_count = 1;		// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;		// Nombre d'affectations executées
	int if_count = 0;		// Nombre de conditions executées
	static int else_count = 0;	// Nombre de else
	extern int elsee;


	bool fin_prog = false;
	bool create_read_proc = false;
	bool create_echo_proc = false;

%}

%token <id> ID
%token <entier> NB
%token <chaine> CCS
%token EG
%token PL
%token MN
%token FX
%token DV
%token OP
%token CP
%token END
%token MR

%token IF
%token THEN
%token FI
%token ELSE
%token DEC
%token OB
%token CB
%token ECH 
%token READ 
%token RTN
%token EXT
%token OA
%token CA 
%token '$'
%token <chaine> MOTS

// Regles de grammaire
%left PL MN
%left FX DV

%union {
	char *id;
	int entier;
	char *chaine;
}

%type <chaine> operande 
%type <entier> operande_entier

%%
programme : instruction END programme 
	  | instruction END 
	  {
	  	if (elsee) {
			elsee--;
			strcat(instructions, "j Fi");
			strcat(instructions, itoa(else_count-1));
			strcat(instructions, "\n");
			strcat(instructions, "Else");
			strcat(instructions, itoa(else_count-1));
			strcat(instructions, ":\n");
		}
	  }
;

instruction : ID EG oper	// Affectation
	    {
		if (find_entry($1) == -1)
			add_tds($1, ENT, 1, 0, 0, 1, "");
	    	findStr($1,ids,1);
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
	    	strcat(instructions, "Else");
		strcat(instructions, itoa(--if_count));
		strcat(instructions, ":\n");
	    }
	| IF bool THEN programme ELSE programme FI
	    {
	    	strcat(instructions, "Fi");
		strcat(instructions, itoa(--if_count));
		strcat(instructions, ":\n");
	    }
	| ECH operande { // Print
		int crea = findStr($2,ids,0);
		if (crea == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$2);
			strcat(data,"\"\n");
			strcat(instructions,"li $a0, _");
			strcat(instructions,itoa(id_count));
			id_count++;
		}
		else { // c'est un id ou une chaine déjà déjà déclaré 
			strcat(instructions,"li $a0, ");
			strcat(instructions,ids[crea]);
		}
		strcat(instructions,"\nli $v0 4\nsyscall\n");
		}
	| ECH '$' OA ID OB operande_entier CB CA {
			printf("ici \n");
			//il faudrait idéalement encore checker la présence ou 
			//pas dans la table des symboles et dans les ids 
			//si pas dedans on échoue 
			if (find_entry($4) == -1)
				yyerror("ID pas dans la table des symboles");
			int check_index = $6;
			if ((check_index) >= get_dim($4))
				yyerror("index + grand que prévu ");	
			strcat(instructions, "la $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", ");
			strcat(instructions, $4);
			//on cherche la bonne place de ce que l'on cherche
			strcat(instructions,"\naddi $t");
			strcat(instructions,itoa(reg_count));
			strcat(instructions, ",$t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", ");
			strcat(instructions , itoa(4*check_index));
			strcat(instructions, "\nlw $a0, ($t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ")\nli $v0, 1\nsyscall\n");
		}		
	| EXT { // Exit 
			printf("passage ici \n");
			strcat(instructions, "li $v0 10\nsyscall\n");
			fin_prog = true;
		}
	| EXT NB { // Exit avec entier
			// interruption ?? 
		}
	| READ ID { // Affect bis 
			if (find_entry($2) == -1)
				add_tds($2,ENT,1,0,0,1,"");
			findStr($2,ids,1);
			strcat(instructions, "la $a0");
			strcat(instructions, ", ");
			strcat(instructions, $2);
			strcat(instructions, "\n");
			strcat(instructions, "li $v0 8\nsyscall\n");
		}
	| READ ID OB operande_entier CB  {
			int crea = 0;
			if ((crea = find_entry($2)) == -1)
				add_tds($2,TAB,1,$4+1,0,1,"");
			//findStr($2,ids,1);
			findStr($2,ids,0); // créa -1 cas particulier
			int ent = $4 + 1;
			if (crea == -1) {
				//creation du tableau
				strcpy(ids[id_count],$2);
				strcat(data,$2);
				strcat(data,":\t.space\t");
				strcat(data,itoa(ent));
				strcat(data,"\n");
			}
			strcat(instructions,"la $t");
			int save_reg = reg_count;
			strcat(instructions,itoa(reg_count));
			strcat(instructions,", ");
			strcat(instructions, $2);
			strcat(instructions, "\naddi $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ",$t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions,", ");
			strcat(instructions,itoa(4*$4)); //on se place au bon endroit
			strcat(instructions, "\n");
			//ensuite on demande : 
			strcat(instructions, "li $v0 5\nsyscall\n");
			//on déplace dans un registre tmp libre
			strcat(instructions, "move $t");
			reg_count++;
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", $v0\n");
			strcat(instructions, "sw $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", ($t");
			strcat(instructions, itoa(save_reg));
			strcat(instructions, ")\n");
			//ok 

		}//bouchon}
	
	| RTN { // Return 
			strcat(instructions, "jr $ra\n");
		}
	| RTN NB { // Return entier
			strcat(instructions, "jr $ra\n");
			// + statut dans $? 
		}
;
bool : NB 
     {
     	strcat(instructions, "li $t0, ");
	strcat(instructions, itoa($1));
	strcat(instructions, "\n");
	strcat(instructions, "beq $t0, $zero, Else");
	strcat(instructions, itoa(else_count));
	strcat(instructions, "\n");
	if_count++;
	else_count++;
     }
;

operande : CCS {$$ = $1 ; printf("iki \n");}
	| '$' OA ID CA {$$ = $3;}
	| '$' NB {$$ = itoa($2);} //check des arguments ici 
	| MOTS {$$ = $1; printf("mot \n");}
	//bouchon}*/
	//manque ici le $*,$? et ${id[<operande_entier>]} , et fini $NB
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

operande_entier : NB
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
int findStr (char *str, char strs[512][64], int crea) {
	for (int i = 0; i < id_count; i++) {
		if (strcmp(str, strs[i]) == 0) {
			return i;
		}
	}
	if (crea) {
		strcpy(strs[id_count], str);
		strcat(data, str);
		strcat(data, ":\t.word\t0\n");
		id_count++;
		return 1;
	}
	return -1;
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
