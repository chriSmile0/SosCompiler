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
	int chaine_vide_ou_non(int true_vide, char *type , char *chaine);
	int proc_or(int left, int right);
	int proc_and(int left, int right);

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
	char procedures[2048];		// Partie procedures
	
	extern int elsee;
	extern int whilee;
	extern int until;

	bool fin_prog = false;
	bool create_read_proc = false;
	bool create_echo_proc = false;
	bool compare_proc = false;
	bool check_v_nv_proc = false;
	bool check_and_proc = false;
	bool check_or_proc = false;

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
	| test_bloc 
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
		$$ = $2;
	}
;

test_expr : test_expr YOU test_expr2 {
		$$ = proc_or($1,$3);
	}
	| test_expr2
;

test_expr2 : test_expr2 YET test_expr3 {
		$$ = proc_and($1,$3);
	}
	| test_expr3
;

test_expr3 : OP test_instruction CP {	// (test_expr)
		$$ = $2;
	}
	| '!' OP test_expr CP {		// !(test_expr)
		if($3 == 1)
			strcat(instructions, "addi $a0 -1\n");
		else 
			strcat(instructions, "addi $a0 1\n");
		$$ = !$3;
	}
	| test_instruction {		// test_instruction
		$$ = $1;
	}
	| '!' test_instruction {	// !test_instruction
		//on inverse la sortie 
		if($2 == 1)
			strcat(instructions, "addi $a0 -1\n");
		else 
			strcat(instructions, "addi $a0 1\n");
		$$ = !$2;
	}
;

test_instruction : concatenation '=' concatenation {
		//il faut stocker le resultat des concat 
		//dans des chaines temporaires
		compare_chaine("beq",$1,$3);
		$$ = (strcmp($1, $3) == 0);
	}
	| concatenation '~' concatenation {
		//il faut stocker le resultat des concat
		//dans des chaines temporaires
		compare_chaine("bne",$1,$3);
		$$ = (strcmp($1, $3) != 0);
		
	}
	| operateur1 CCS {
		//sprintf($$,"%s %s ",$1,$2);
		//pas sur de ça 
		int crea = findStr($2,ids,0);
		char id_str1[100];
		if (crea == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$2);
			strcat(data,"\"\n");
			sprintf(id_str1,"_%s",itoa(id_count));
			add_tds(id_str1, CH, 0, -1, -1, 0, $2);
			id_count++;
		}
		else {
			sprintf(id_str1, "%s", ids[crea]);
		}
		chaine_vide_ou_non(strlen($2),$1 , id_str1);
		$$ = strlen($2); // > 0 non vide 
	}
	| CCS operateur2 CCS {
		int crea_entry = find_entry($1);
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
			add_tds(id_str1, CH, 0, -1, -1, 0, $1);
			id_count++;
		}
		else {
			sprintf(id_str1, "%s", ids[crea]);
		}
		crea_entry = find_entry($3);
		crea = findStr($3,ids,0);
		if (crea_entry == -1) { 
			strcat(data,"_");
			strcat(data,itoa(id_count));
			strcat(data,":\t.asciiz \"");
			strcat(data,$3);
			strcat(data,"\"\n");
			sprintf(id_str2,"_%s",itoa(id_count));
			add_tds(id_str2, CH, 0, -1, -1, 0, $3);
			id_count++;
		}
		else {
			sprintf(id_str2, "%s", ids[crea]);
		}
		compare_chaine($2,id_str1,id_str2);
		$$ = (strcmp($1,$3)==0);
	}
;

operateur1 : YCCNV {$$ = "-n";}
	| YCCV {$$ = "-z";}
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
	// 1 pour egal , 0 pour differentes 
	// ** 0 -> != 1 -> = , 2 -> < , 3 -> <= , 4 -> > , 5-> >= ** //

	int type_cmpr = -1;
	//int retour = 0;
	if (strcmp(type,"bge")==0)
		type_cmpr = 5;
	else if (strcmp(type,"bgt")==0)
		type_cmpr = 4;
	else if (strcmp(type,"ble")==0)
		type_cmpr = 3;
	else if (strcmp(type,"blt")==0)	
		type_cmpr = 2;
	else if (strcmp(type, "beq")==0)
		type_cmpr = 1;
	else if (strcmp(type, "bne")==0) 
		type_cmpr = 0;
	if (!compare_proc) {
		char compare_s[1000];
        sprintf(compare_s,"%s","compare_strvdeux:\n\tli $t1 , 0\n\tla $v1 , ($a0)\n\tloop_cmp:\n\tlb $t2 , ($a0)\n\tlb $t3 , ($a1)\n\tbeqz $t2 , end_cmpv\n\tbeqz $t3 , end_cmpvf\n\tmove $t4 , $t2\n\tmove $t5 , $t3\n\t");
		strcat(compare_s, "addi $t4, $t4, -48\n\taddi $t5, $t5, -48\n\tmove $t6 , $a0\n\tbne $t4,$t5 not_equalv\n\tli $v0 11\n\tmove $a0,$t2\n\tmove $a0 , $t6\n\t");
		strcat(compare_s, "addi $a0, $a0 , 1\n\taddi $a1, $a1 , 1\n\tj loop_cmp\nnot_equalv:\n\tli $t4 ,0\n\tbeq $a2 ,2 true_little\n\tbeq $a2 ,3 egal_little\n\t");
		strcat(compare_s, "move $a0 $t4\n\tjr $ra\ntrue_little:\n\taddi $a0 $zero 2\n\tjr $ra\negal_little:\n\taddi $a0 $zero 3\n\tjr $ra\nnot_equalvf:\n\tli $t4 ,0\n\t");
        strcat(compare_s, "beq $a2 ,4 true_bigger\n\tbeq $a2 ,5 egal_bigger\n\tmove $a0 $t4\n\tjr $ra\ntrue_bigger:\n\taddi $a0 $zero 4\n\tjr $ra\negal_bigger:\n\t");
        strcat(compare_s, "addi $a0 $zero 5\n\tjr $ra\nend_cmpv:\n\tli $t4 , 1\n\tmove $t5 , $a2\n\tlb $t3 , ($a1)\n\tla $v1 ($a1)\n\tbnez $t3 not_equalv\n\tmove $a0 , $t4\n\t");
        strcat(compare_s, "jr $ra\nend_cmpvf:\n\tli $t4 , 1\n\tmove $t5 , $a2\n\tlb $t3 , ($a0)\n\tla $v1 ($a0)\n\tbnez $t3 not_equalvf\n\tmove $a0 , $t4\n\tjr $ra\n");
		strcat(procedures,compare_s);
		compare_proc = true;
	}	
	sprintf(buf,"la $a0 %s",str1);
	strcat(buf, "\nla $a1 ");
	strcat(buf, str2);
	strcat(buf, "\nli $a2 ");
	strcat(buf, itoa(type_cmpr));
	strcat(buf, "\njal compare_strvdeux\n");
	strcat(buf, "move $t");
	strcat(buf, itoa(reg_count));
	strcat(buf, " $a0 \n");
	sprintf(buffer,"%s",buf);
	strcat(instructions, buffer);
	
	(void) type;
}

int chaine_vide_ou_non(int true_vide , char *type , char *chaine) {
	//1 pour vide, 0 pour non vide si type == -z
	//0 pour vide, 1 pour non vide si type == -n
	if (!check_v_nv_proc) {
		strcat(procedures , "proc_v_nv:\n\tlb $t0 ($a0)\n\tbeqz $t0 pasvide\n\taddi $a0 , $zero , 0\n\tjr $ra\npasvide:\n\taddi $a0 , $zero , 1\n\tjr $ra\n\n");
		check_v_nv_proc = true;
	}
	strcat(instructions, "la $a0 ");
	strcat(instructions, chaine);
	strcat(instructions, "\njal proc_v_nv\n");
	if (strcmp(type,"-n")==0) {
		if(true_vide) //pas vide 
			strcat(instructions, "addi $a0 , 1\n");
	}

	//print result avec print_int 
	(void) type;
	return 1;
}

int proc_or(int left, int right) {
	if (!check_or_proc) {
		strcat(procedures, "proc_or:\n\tor $t0 ,$a0,$a1\n\tmove $a0 $t0\n\tjr $ra\n\n");
		check_or_proc = true;
	}
	strcat(instructions,"jal proc_or\n");
	return (left || right);
}

int proc_and(int left, int right) {
	if (!check_and_proc) {
		strcat(procedures, "proc_and:\n\tand $t0 ,$a0,$a1\n\tmove $a0 $t0\n\tjr $ra\n\n");
		check_and_proc = true;
	}
	strcat(instructions, "move $a1, $t");
	strcat(instructions, itoa(reg_count-1));
	strcat(instructions, "\nmove $a0, $t");
	strcat(instructions, itoa(reg_count-2));
	strcat(instructions, "\n");
	reg_count -= 2;
	strcat(instructions,"jal proc_and\n");
	return (left && right);
}
