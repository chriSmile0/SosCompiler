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
	void genElse();
	void genFi();
	void genWhile();

	char data[1024];			// Partie declaration des variables
	char instructions[4096];	// Partie instructions
	char procedures[4096];		// Partie procedures/fonctions
	char * buf = instructions;	// Buffer à utiliser pour la génération MIPS, utile pour les fonctions
	char ids[512][64];			// Tableau des identificateurs
	int id_count = 0;			// Nombre d'identificateurs
	int reg_count = 1;			// Sur quel registre temporaire doit-on ecrire
	int li_count = 0;			// Nombre d'affectations executées
	int pileWhile[512];			// Pile des while
	int i_while = 0;			// Indice de la pile des while
	int pileElse[512];			// Pile des else
	int if_count = 0;			// Indice de la pile des else utilisé pour Else
	int fi_count = 0;			// Indice de la pile des else utilisé pour Fi
	int else_count = 0;			// Prochaine valeur entiere à coller au prochaine label else (ex : "Else4:")
	int while_count = 0;		// Prochaine valeur entiere à coller au prochaine label while (ex : "While4:")
	// Check .lex
	extern int elsee;
	extern int whilee;
	extern int until;

	bool fin_prog = false;
	bool create_read_proc = false;
	bool create_echo_proc = false;

	extern char * last_id;  // Nom du dernier id rencontré
	extern int in_func; 	// Bool pour savoir si on est dans une fonction 
	int set = 0;			// Bool pour la mise en place du label de fonction

%}

%union {
	char *id;
	int entier;
	char* chaine;
}

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
%token OB
%token CB
%token SC

%token LOCAL
%token EXPR
%token IF
%token THEN
%token FI
%token ELSE
%token WHL
%token DO
%token DONE
%token UTL
%token DEC
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

%type <chaine> operande 
%type <entier> operande_entier

%%
programme : %empty {
}
		  | instruction SC programme {

	  	if (elsee) { // Si l'instruction sur laquelle on est est un else, alors on est dans une instruction de type IF ... THEN ... ELSE ... FI
			// Il faut donc un label Fi pour sortir une fois la condition réussie
			strcat(buf, "j Fi");
			strcat(buf, itoa(pileElse[fi_count-1]));
			strcat(buf, "\n");
			genElse("Else");
			elsee--;
		}
}


;

instruction : ID EG oper {	// Affectation
		if (in_func && find_entry($1) == -1){
			yyerror("Déclaration d'un id global dans une fonction.\n");
		}
		if (find_entry($1) == -1)
			add_tds($1, ENT, 1, 0, 1, "");
	    findStr($1,ids,1);
		strcat(buf, "sw $t");
		strcat(buf, itoa(reg_count-1));
		strcat(buf, ", ");
		strcat(buf, $1);
		strcat(buf, "\n");
		reg_count = 1;
		li_count = 0;
}
			| DEC ID OB NB CB { // Déclaration de tableau
		if (find_entry($2) == -1)
			add_tds($2, TAB, 1, $4, 1, "");

		// Buffer contenant la ligne à intégrer dans ".data" du MIPS
		char buff[64];
		size_t max_length = sizeof(buff);
		int ret = snprintf(buff, max_length, "%s:\t.space\t%d\n\t.align\t4"
			"\n", $2, $4);

		if (ret >= max_length)
			fprintf(stderr, "|ERREUR| Dépassement du buffer - Dec tab");

		strcat(data, buff);
}
			| IF bool THEN programme FI {
	    	genElse();
}
			| IF bool THEN programme ELSE programme FI {
	    	genFi();
}
	    	| WHL bool DO programme DONE {
		genWhile();
	    genElse();
}
	    	| UTL bool DO programme DONE {
		genWhile();
		genElse();
}
			| ECH operande { // Print
		int crea = findStr($2,ids,0);
		if (crea == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$2);
			strcat(data,"\"\n");
			strcat(buf,"la $a0, _");
			strcat(buf,itoa(id_count));
			strcat(buf, "\n");
			id_count++;
			if (in_func) {
				strcat(buf, "move $v1, $a0\n");
			}
		}
		else { // c'est un id ou une chaine déjà déjà déclaré 
			strcat(buf,"la $a0, ");
			strcat(buf,ids[crea]);
			strcat(buf, "\n");
			if (in_func) {
				strcat(buf, "move $v1, $a0\n");
			}
		}
		strcat(buf,"li $v0 4\nsyscall\n");
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
		reg_count++;	
		strcat(buf, "la $t");
		strcat(buf, itoa(reg_count));
		strcat(buf, ", ");
		strcat(buf, $4);
		//on cherche la bonne place de ce que l'on cherche
		strcat(buf,"\naddi $t");
		strcat(buf,itoa(reg_count));
		strcat(buf, ", $t");
		strcat(buf, itoa(reg_count));
		strcat(buf, ", ");
		strcat(buf , itoa(4*check_index));
		strcat(buf, "\nlw $a0, ($t");
		strcat(buf, itoa(reg_count));
		strcat(buf, ")\n");
		if (in_func) {
			strcat(buf, "move $v1, $a0\n");
		}
		strcat(buf, "li $v0, 4\nsyscall\n");
		reg_count--;
}
			| EXT { // Exit 
			strcat(buf, "li $v0 10\nsyscall\n");
			fin_prog = true;
}
			| EXT NB { // Exit avec entier
			// interruption ?? 
}
			| READ ID { // Affect bis 
		if (find_entry($2) == -1)
			add_tds($2,ENT,1,0,1,"");
		findStr($2,ids,1);
		strcat(buf, "la $a0");
		strcat(buf, ", ");
		strcat(buf, $2);
		strcat(buf, "\n");
		strcat(buf, "li $v0 8\nsyscall\n");
}
			| READ ID OB operande_entier CB  {
		if (find_entry($2) == -1)
			yyerror("ID pas dans la table des symboles");

		if ($4 >= get_dim($2))
			yyerror("Indice utilisé plus grand que le tableau");

		// Créé un buffer dans ".data", s'il n'existe pas encore
		if (find_entry("buffer") == -1){
			add_tds("buffer", CH, 1, 0, 1, "");
			strcat(data, "buffer:\t.space\t10000\n");
		}

		// Paramétrage du "read string"
		// Adresse de stockage de l'input
		// Maximum de caractères à lire, puis syscall "read string"
		strcat(buf, "la $a0, buffer\n");
		strcat(buf, "li $a1, 10000\n");
		strcat(buf, "li $v0, 8\n");
		strcat(buf, "syscall\n");

		// On détermine l'index du tableau souhaité
		strcat(buf, "addi $t");
		strcat(buf, itoa(reg_count));
		strcat(buf, ", $zero, ");
		strcat(buf, itoa(4 * $4));
		strcat(buf, "\n");

		// On enregistre
		strcat(buf, "sw $a0, ");
		strcat(buf, $2);
		strcat(buf, "($t");
		strcat(buf, itoa(reg_count));
		strcat(buf, ")\n");
}
			| RTN { // Return 
		strcat(buf, "jr $ra\n");
}
			| RTN NB { // Return entier
		strcat(buf, "li $v0, ");
		strcat(buf, itoa($2));
		strcat(buf, "\n");
		strcat(buf, "jr $ra\n");

		
}

			| decl_fonc 
			| appel_fonc 
;

bool : NB {
	if (whilee) { // Si l'instruction sur laquelle on est est un while, alors on est dans une instruction de type WHILE ... DO ... DONE
		// Il faut donc un label While pour y retourner
		strcat(buf, "While");
		strcat(buf, itoa(while_count));
		strcat(buf, ":\n");
		pileWhile[i_while] = while_count;
		whilee--;
		while_count++;
		i_while++;
		fi_count--;
	}
	if (until) { // Si l'instruction sur laquelle on est est un until, alors on doit sortir uniquement si la condition réussit
		strcat(buf, "li $t0, ");
		strcat(buf, itoa($1));
		strcat(buf, "\nli $t1, ");
		strcat(buf, itoa(1));
		strcat(buf, "\nbeq $t0, $t1, Else");
		strcat(buf, itoa(else_count));
		strcat(buf, "\n");
		until--;
		pileElse[if_count] = else_count;
		else_count++;
		if_count++;
		fi_count++;
	} else { // Sinon, on doit sortir uniquement si la condition échoue
		strcat(buf, "li $t0, ");
		strcat(buf, itoa($1));
		strcat(buf, "\n");
		strcat(buf, "beq $t0, $zero, Else");
		strcat(buf, itoa(else_count));
		strcat(buf, "\n");
		pileElse[if_count] = else_count;
		else_count++;
		if_count++;
		fi_count++;
	}
}
;

liste_operande : liste_operande operande 
			   | operande  			   
;

operande : CCS {$$ = $1 ;}
		 | '$' OA ID CA {$$ = $3;}
		 | '$' NB {$$ = itoa($2);} //check des arguments ici 
		 | MOTS {$$ = $1; printf("mot \n");}
	//	 | '$' OP appel_fonc CP
		//bouchon}*/
		//manque ici le $*,$? et ${id[<operande_entier>]} , et fini $NB
;


oper : unique
     | oper PL oper {operation("add");}
     | oper MN oper {operation("sub");}
     | oper FX oper {operation("mul");}
     | oper DV oper {operation("div");}
     | OP oper CP 
     | MN oper %prec MN {
	strcat(buf, "li $t");
	strcat(buf, itoa(reg_count));
	strcat(buf, ", -1\n");
    strcat(buf, "mul $t");
	strcat(buf, itoa(reg_count-1));
	strcat(buf, ", $t");
	strcat(buf, itoa(reg_count-1));
	strcat(buf, ", $t");
	strcat(buf, itoa(reg_count));
	strcat(buf, "\n");
}
;

operande_entier : NB
;

unique : ID {
    li_count++;
 	if (find_entry($1) == -1)
		yyerror("ID pas dans la tds.");
	strcat(buf,"lw $t");
	strcat(buf,itoa(reg_count));
	strcat(buf,", ");
	strcat(buf,$1);
	strcat(buf,"\n");
	reg_count++;
}
       | NB {
    li_count++;
	strcat(buf,"li $t");
	strcat(buf,itoa(reg_count));
	strcat(buf,", ");
	strcat(buf,itoa($1));
	strcat(buf,"\n");
	reg_count++;
}
;

decl_fonc : ID OP CP OA decl_loc programme CA {
		if (find_entry($1) != -1)
			yyerror("ID de la fonction déjà dans la tds.\n");
		add_tds($1, FCT, 1, 0, 1, "");
		strcat(buf, "jr $ra\n\n");
		//on remet en place les variables pour la sortie de fonction
		set = 0;
		in_func = 0;
		buf = instructions;
}
;

decl_loc : %empty { 
		//on print le label de la fonction courante (récupéré avec lex)
		if (!set){
			in_func = 1;
			buf = procedures;
			strcat(buf, last_id);
			strcat(buf, ":\n");
			set = 1;
		} else {
			yyerror("Declaration de locale hors fonction.\n");
		}
}
		 | decl_loc LOCAL ID EG oper SC {
		if (!set){
			in_func = 1;
			buf = procedures;
			strcat(buf, last_id);
			strcat(buf, ":\tn");
			set = 1;
		} else {
			yyerror("Declaration de locale hors fonction.\n");
		}
		if (find_entry($3) != -1)
			yyerror("ID de la variable locale déjà dans la tds.\n");
		add_tds($3, CH, 1, 0, 0, last_id);
}
;

appel_fonc : ID {
	//Génération mips appel de la fonction
	//Si on est dans une fonction on doit stocker la valeur de $ra
		if(in_func){
			strcat(buf, "addi $sp, $sp, -4\n");
			strcat(buf, "sw $ra, 0($sp)\n");
		}
		strcat(buf, "jal ");
		strcat(buf, $1);
		strcat(buf, "\n");
	//Si on est dans une fonction on doit rétablir la valeur de $ra	
		if (in_func) {
			strcat(buf, "lw $ra, 0($sp)\n");
			strcat(buf, "add $sp, $sp, 4\n");
		}
}
		   | ID liste_operande {
		if (!in_func && strcmp(get_fonc($1), "") != 0 && get_type($1) == FCT){
	//Génération mips appel de la fonction avec argument(s)
	//manque load arguments dans $a 
		if(in_func){
			strcat(buf, "addi $sp, $sp, -4\n");
			strcat(buf, "sw $ra, 0($sp)\n");
		}
		strcat(buf, "jal ");
		strcat(buf, $1);
		strcat(buf, "\n");
		if (in_func) {
			strcat(buf, "lw $ra, 0($sp)\n");
			strcat(buf, "add $sp, $sp, 4\n");
		}
	}
}


%%
// Fonction qui execute une operation entre les deux derniers registres
// temporaires utilisés
void operation(char *str) {
	strcat(buf, str);
	strcat(buf, " $t");
	if (li_count <= 2)
		strcat(buf,"0");
	else
		strcat(buf, itoa(reg_count-2));
	strcat(buf, ", $t");
	strcat(buf, itoa(reg_count-2));
	strcat(buf, ", $t");
	strcat(buf, itoa(reg_count-1));
	strcat(buf, "\n");
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

void genElse() {
	strcat(buf, "Else");
	strcat(buf, itoa(pileElse[--if_count]));
	strcat(buf, ":\n");
}

void genFi() {
	strcat(buf, "Fi");
	strcat(buf, itoa(pileElse[--fi_count]));
	strcat(buf, ":\n");
}

void genWhile() {
	strcat(buf, "j While");
	strcat(buf, itoa(pileWhile[--i_while]));
	strcat(buf, "\n");
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

void resetVars() {
	i_while = 0;
	if_count = 0;
	fi_count = 0;
	else_count = 0;
	while_count = 0;
	elsee = 0;
	whilee = 0;
	until = 0;
}
