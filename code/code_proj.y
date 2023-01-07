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
	int compare_chaine(char *type, char *str1, char *str2);

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

	bool fin_prog = false;
	bool create_read_proc = false;
	bool create_echo_proc = false;
	bool compare_proc = false;

%}

%token <id> ID
%token <entier> NB
%token <chaine> CCS

%token <chaine> TEST
%token YOU YET

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
%token WHL
%token DO
%token DONE
%token UTL
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

%token YCCNV YCCV YGE YGT YLE YLT YEQ YNE YNOP '!' '~'

%type <entier> instruction
%type <chaine> concatenation
%type <entier> test_bloc test_expr test_expr2 test_expr3 test_instruction
%type <chaine> operande
%type <chaine> operateur2 operateur1

// Regles de grammaire
%left PL MN
%left FX DV

%union {
	char *id;
	int entier;
	int boolean;
	char *chaine;
}

%type <entier> operande_entier

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
			int ret = snprintf(buff, max_length, "%s:\t.space\t%d\n\t.align\t4"
				"\n", $2, $4);

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
			reg_count++;	
			strcat(instructions, "la $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", ");
			strcat(instructions, $4);
			//on cherche la bonne place de ce que l'on cherche
			strcat(instructions,"\naddi $t");
			strcat(instructions,itoa(reg_count));
			strcat(instructions, ", $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", ");
			strcat(instructions , itoa(4*check_index));
			strcat(instructions, "\nlw $a0, ($t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ")\nli $v0, 4\nsyscall\n");
			reg_count--;
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
			if (find_entry($2) == -1)
				yyerror("ID pas dans la table des symboles");

			if ($4 >= get_dim($2))
				yyerror("Indice utilisé plus grand que le tableau");

			// Créé un buffer dans ".data", s'il n'existe pas encore
			if (find_entry("buffer") == -1){
				add_tds("buffer", CH, 1, 0, -1, 1, "");
				strcat(data, "buffer:\t.space\t10000\n");
			}

			// Paramétrage du "read string"
			// Adresse de stockage de l'input
			// Maximum de caractères à lire, puis syscall "read string"
			strcat(instructions, "la $a0, buffer\n");
			strcat(instructions, "li $a1, 10000\n");
			strcat(instructions, "li $v0, 8\n");
			strcat(instructions, "syscall\n");

			// On détermine l'index du tableau souhaité
			strcat(instructions, "addi $t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ", $zero, ");
			strcat(instructions, itoa(4 * $4));
			strcat(instructions, "\n");

			// On enregistre
			strcat(instructions, "sw $a0, ");
			strcat(instructions, $2);
			strcat(instructions, "($t");
			strcat(instructions, itoa(reg_count));
			strcat(instructions, ")\n");
		}
	| RTN { // Return 
			strcat(instructions, "jr $ra\n");
		}
	| RTN NB { // Return entier
			strcat(instructions, "jr $ra\n");
			// + statut dans $? 
		}
	| test_expr 
	| test_bloc
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
	| MN oper %prec MN {
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

test_bloc : TEST test_expr {
		printf("========> YACC <========\n");
		$$ = 1;
	}
;

test_expr : test_expr YOU test_expr2 {
		sprintf(instructions, "li $t0, %d\n", $1);
		sprintf(instructions, "li $t1, %d\n", $3);
		strcat(instructions, "or $t3, $t0, $t1\n");
		$$ = ($1 || $3);
	}
	| test_expr2
;

test_expr2 : test_expr2 YET test_expr3 {
		sprintf(instructions, "li $t0, %d\n", $1);
		sprintf(instructions, "li $t1, %d\n", $3);
		strcat(instructions, "and $t3, $t0, $t1\n");
		//sprintf($$, "li $t0, %s\nli $t1, %s\n and $t3, t0, $t1\n",$1,$3);
		$$ = ($1 && $3);
	}
	| test_expr3 {printf("expr 3 \n");$$ = $1;}
;

test_expr3 : OP test_expr CP {	// (test_expr)
		//$$ = $2;
	}
	| '!' OP test_expr CP {		// !(test_expr)
		//$$ = !$3;
	}
	| test_instruction {		// test_instruction
		$$ = $1;
	}
	| '!' test_instruction {	// !test_instruction
		//$$ = !$2;
	}
;

test_instruction : concatenation '=' concatenation {
		compare_chaine("beq",$1,$3);
		printf("compare_chaine \n");
		$$ = (strcmp($1, $3) == 0);
	}
	| concatenation '~' concatenation {
		$$ = (strcmp($1, $3) != 0);
		
	}
	| operateur1 concatenation {
		//sprintf($$,"%s %s ",$1,$2);
		//pas sur de ça 
		$$ = 1;
	}
	| operande_entier operateur2 operande_entier {
		//sprintf($$,"%s %s %s ",$1,$2,$3);
		printf("operateur 2 : \n");
		$$ = 1;
	}
	| CCS operateur2 CCS {
		int crea = findStr($1,ids,0);
		char id_str1[100];
		char id_str2[100];
		if (crea == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$1);
			strcat(data,"\"\n");
			sprintf(id_str1,"_%s",itoa(id_count));
			id_count++;
		}
		else {
			sprintf(id_str1, "%s", ids[crea]);
		}
		crea = findStr($3,ids,0);
		if (crea == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$3);
			strcat(data,"\"\n");
			sprintf(id_str2,"_%s",itoa(id_count));
			id_count++;
		}
		else {
			sprintf(id_str2, "%s", ids[crea]);
		}
		printf("id _str1 : %s\n",id_str1);
		printf("id _str2 : %s\n",id_str2);
		compare_chaine($2,id_str1,id_str2);
		printf("compare chaine \n");
		//sprintf($$,"%s %s %s ",$1,$2,$3);

		printf("operateur 2 avec operande: \n");
		$$ = 1;
	}
;

operateur1 : YCCNV {$$ = "beqz";}
	| YCCV {$$ = "beqa";}
;

operateur2 : YEQ {$$ = "beq";}
	| YNE {$$ = "bne";}
	| YGT {$$ = "bgt";}
	| YGE {$$ = "bge";}
	| YLT {$$ = "blt";}
	| YLE {$$ = "ble";}
;

concatenation : concatenation operande {
		concat_data($1, $2);
		$$ = $1;
	}
	| operande
	| operande_entier {printf("ici \n");$$ = itoa($1);}
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

int compare_chaine(char *type, char *str1, char *str2) {
	char buffer[400];
	char buf[400];
	printf("dans la fct de comparaison \n");
	if (!compare_proc) {
		int type_not_equal = -10;
		int type_end_cmp = -10;
		if(strcmp(type,"beq")==0) {
			type_not_equal = 1;
			type_end_cmp = 0;
		}
		char strlen[200] = "strlen:\n\tli $t2, 0\n\tloop_len:\n\tlb $t1 , 0($a0)\n\tbeqz $t1, exit_fnclen\n\taddi $a0, $a0 , 1\n\taddi $t2 , $t2 , 1\n\tj loop_len\nexit_fnclen:\n\tmove $a0, $t2\n\tjr $ra\n\n";
		char compare_s[1000];
		sprintf(compare_s, "compare_str:\n\tmove $t0 $a2\n\tmove $t1 $a3\n\tbeq $t0,$t1 not_equal\n\t");
		strcat(compare_s, "li $t1 , 0\n\tloop_cmp:\n\tlb $t2 , ($a0)\n\tlb $t3 , ($a1)\n\tli $t1 , 0\n\t loop_cmp:\n\tlb $t2 , ($a0)\n\tlb $t3 , ($a1)\n\t");
		strcat(compare_s, "beqz $t2 , end_cmp\n\tmove $t4 , $t2\n\tmove $t5 , $t3\n\taddi $t4, $t4, -48\n\taddi $t5, $t5, -48\n\tmove $t6 , $a0\n\t");
		strcat(compare_s, "bne $t4,$t5 not_equal\n\tli $v0 11\n\tmove $a0,$t2\n\tsyscall\n\tmove $a0 , $t6\n\taddi $a0, $a0 , 1\n\taddi $a1, $a1 , 1\n\tj loop_cmp\n");
		strcat(compare_s, "not_equal:\n\tli $t0 ,"); 
		strcat(compare_s, itoa(type_not_equal));
		strcat(compare_s, "\n\tmove $a0 $t0\n\tjr $ra\nend_cmp:\n\tli $t0 , ");
		strcat(compare_s, itoa(type_end_cmp));
		strcat(compare_s , "\n\tmove $a0 $t0\n\tjr $ra\n\n");
		strcat(instructions ,strlen);
		strcat(instructions ,compare_s);
		printf("%s",strlen);
		printf("%s",compare_s);
	}	
	sprintf(buf, "la $a0 %s\n",str1);
	printf("bufff : %s\n",buf);
	strcat(buf, "jal strlen\nmove $t");
	strcat(buf, itoa(reg_count));
	strcat(buf, " $a0\nla $a0 ");
	strcat(buf, str2);
	strcat(buf, "\njal strlen\nmove $t");
	strcat(buf, itoa(reg_count+1));
	strcat(buf, " $a0\nla $a0 ");
	strcat(buf, str1);
	strcat(buf, "\nla $a1 ");
	strcat(buf, str2);
	strcat(buf, "\nmove $a2 $t");
	strcat(buf, itoa(reg_count));
	strcat(buf, "\nmove $a3 $t");
	strcat(buf, itoa(reg_count+1));
	strcat(buf, "\njal compare_str\n");
	printf("buf :|%s|\n",buf);
	sprintf(buffer,"%s",buf);
	printf("buffer : %s\n",buffer);
	// le resultat est dans $a0
	strcat(instructions, buffer);
	compare_proc = true;
	
	/*if (type == '~') {

	}


	else if (type == '=') {
		
	}*/
	(void) type;
	return 1;
}
