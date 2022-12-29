#include "../inc/fct_yacc.h"


int traiter_nombre(char *nb) {
	if (nb[0] == '-') {
		nb++;
		return -(atoi(nb));
	}
	else {
		return atoi(nb);
	}
}

char * rtn_arg(int index_arg, char * list_arguments) {
	//si on estime que les arguments sont stockés en chaine de caracteres
	int len = strlen(list_arguments);
	int cpt_arg = 0;
	//check des espaces dans la ligne
	int len_arg = 0;
	int arg_idx = 0;
	int found = 0;
	int fin_chaine = 0;
	for (int i = 0 ; i < len; i++) {
		if ((list_arguments[i] == ' ') || (i == len-1)) {
			cpt_arg++;
			if (cpt_arg == index_arg) {
				if (i == len-1)
					fin_chaine = 1;
				i = len;
				arg_idx -= (len_arg+1);
				found = 1;
			}
			else {
				len_arg = 0;
			}
		}
		else {
			len_arg++;
		}
		arg_idx++;
	}
	if (found) {
		int total_len = len_arg+fin_chaine;
		char *arg = malloc((total_len));
		snprintf(arg,total_len+1,"%s",list_arguments+arg_idx);
		arg[total_len] = '\0';
		return arg;
	}
	fprintf(stderr,"Erreur sur l'index de l'argument \n");
	exit(EXIT_FAILURE);
}

char * traiter_arg(char *ligne_arg, char *list_argumens) {
	if (ligne_arg[0] == '?') {//$?
		return "??";
	}
	else if (ligne_arg[0] == '*') {//$*
		return "**";
	}
	else {//$entier
		return rtn_arg((atoi(ligne_arg)),list_argumens);
	}
}


void int_in_str(int e, char tab[],int index_dep) {
	for(int i = 0 ; i < index_dep; i++) // on pad avec une lettre 
		tab[i] = 'a';
	sprintf(tab+index_dep,"%d",e);
} 


int cherche_id(char *id)
{
	int i = 0;
	int size_table = table.taille;
	while ((strcmp(table.champs[i].id,id)!=0) 
		&& (i < size_table))
		i++;
	if (i==size_table)
		return -1;
	return i;
}

int ajout_chaine(char *id, char *chaine)
{
	int result_cherche = 0;
	if((result_cherche = cherche_id(id))!=-1)
		return result_cherche;
	snprintf(table.champs[table.taille].id,50,"%s",id);
	table.champs[table.taille].id[strlen(id)] = '\0';
	snprintf(table.champs[table.taille].valeur,50,"%s",chaine);
	table.champs[table.taille].valeur[strlen(chaine)] = '\0';
	table.taille++;
	return (table.taille-1);
}

char * str_value_of_id(char *id) {
	int result_recherche = 0;
	if ((result_recherche = cherche_id(id))==-1) {
		fprintf(stderr,"Erreur id introuvable dans la table\n");
		exit(EXIT_FAILURE);
	}
	return table.champs[result_recherche].valeur;
}

void print_table_symboles() {
	int taille_table = table.taille;
	for(int i = 0 ; i < taille_table; i++)
		printf("id: %s, valeur : %s\n",table.champs[i].id,table.champs[i].valeur); 
}


//REGISTRES 
int cherche_registre(char *reg) {
	int i = 0;
	int size_table = t_reg.taille;
	while((strcmp(t_reg.registres[i].id,reg)!=0) 
		&& (i < size_table))
		i++;
	if(i==size_table)
		return -1;
	return i;
}

int reg_libre_of_type(char type) {
	int i = 0;
	while ((t_reg.registres[i].type[0] == type)
		&& (t_reg.registres[i].utiliser == 1))
		i++;
	if (i == 9) {//il faut passer a un autre type de registre
		fprintf(stderr,"Choisir un autre type \n");
		return -1;
	}
	return i;
}

char * ajout_value_in_reg(char *reg, char *valeur) {
	int result_cherche = -1;
	if (((result_cherche = cherche_registre(reg))!=-1) 
		&& (t_reg.registres[result_cherche].utiliser == 0))
		return reg;
	else if (result_cherche >= 0) {
		//return du suivant qui est libre (juste au dessus , qui est du même type)
		result_cherche = reg_libre_of_type(reg[1]);
	}
	if(result_cherche > 0) {
		//passage par le else if 
		int len_reg = strlen(reg);
		char res = (result_cherche + '0');
		char *copie_reg = malloc(len_reg+1);
		copie_reg[0] = '\0';
		snprintf(copie_reg,len_reg+1,"%s",reg);
		copie_reg[len_reg-1] = res;
		reg = malloc(len_reg+1);
		snprintf(reg,len_reg+1,"%s",copie_reg);
		reg[len_reg] = '\0';
	}
	snprintf(t_reg.registres[t_reg.taille].id,50,"%s",reg);
	t_reg.registres[t_reg.taille].id[strlen(reg)] = '\0';
	snprintf(t_reg.registres[t_reg.taille].valeur,50,"%s",valeur);
	t_reg.registres[t_reg.taille].valeur[strlen(valeur)] = '\0';
	snprintf(t_reg.registres[t_reg.taille].type,2,"%c",reg[1]);
	t_reg.registres[t_reg.taille].type[1] = '\0';
	t_reg.registres[t_reg.taille].utiliser = 1;
	t_reg.taille++;
	return reg;
}

char * str_value_of_reg(char *reg) {
	int result_recherche = 0;
	if ((result_recherche = cherche_registre(reg))==-1) {
		fprintf(stderr,"Erreur registre introuvable dans la table des reg\n");
		exit(EXIT_FAILURE);
	}
	return t_reg.registres[result_recherche].valeur;
}

void print_table_registre() {
	int taille_table_r = t_reg.taille;
	for(int i = 0 ; i < taille_table_r; i++)
		printf("reg---: %s, valeur : %s\n",t_reg.registres[i].id,
			t_reg.registres[i].valeur); 
}

//MIPS PART
void int_in_register(char *res, int value, FILE *dest) {
	char buf[1024];
	char *line = "\n\tli ";
	char str_value[16]; 
	int_in_str(value,str_value,0);
	//check validité du registre 
	char * reg_choisi = ajout_value_in_reg(res,str_value);
	int len_res = strlen(res);
	res = malloc(len_res+1);
	snprintf(buf,1024,"%s%s %s",line,reg_choisi,str_value);
	int spaces = 1;

	buf[strlen(line)+strlen(reg_choisi)+strlen(str_value)+spaces] = '\0';
	fwrite(buf,strlen(buf),1,dest);
}

char * recherche_reg(char * value) {
	int taille_t_reg = t_reg.taille;
	int i = taille_t_reg;
	while ((i >= 0) && (strcmp(t_reg.registres[i].valeur,value)!=0))
		i--;
	if (i == -1) {
		fprintf(stderr,"Aucun registre ne correspond à la recherche \n");
		return "NULL";
	}
	return t_reg.registres[i].id;
}

void ope_arith_mips(int res_dest,int  res_left, int res_right, char sign) {
	//fwrite()
	//recherche registre of val 
	printf("signe : %c\n",sign);
	char *signe = malloc(5);//max = mult
	signe[0] = '\0';
	switch (sign) {
		case '+':
			snprintf(signe,4,"%s","add");
			break;
		case '-':
			snprintf(signe,4,"%s","sub");
			break;
		case '/':
			snprintf(signe,4,"%s","div");
			break;
		case '*':
			snprintf(signe,4,"%s","mul");
			break;
		case '%':
			//cas particulier en mips
			break;
		default: 
			break;
	}
	printf("signe : %s\n",signe);
	char **reg;
	reg = (char**)malloc(sizeof(char*)*3);
	if(reg != NULL) 
		for(int i = 0 ; i < 3; i++) {
			reg[i] = malloc(4);
			reg[i][0] = '\0';
		}
	int tab_value[3] = {res_dest,res_left,res_right};
	char tab_tmp[16];//taille peut varié ici 
					//et pas toujours des int en entrée
	//
	//rechercher un registre qui correspond à la valeur rechercher
	//on commence par la droite 
	for (int i = 2 ; i >= 0;i--) {
		int_in_str(tab_value[i],tab_tmp,0);
		reg[i] = recherche_reg(tab_tmp);
	}
	char buf[1024];
	char *line = "\n\t";
	snprintf(buf,1024,"%s%s %s %s %s",line,signe,reg[0],reg[1],reg[2]);
	int spaces = 3;
	buf[strlen(line)+strlen(signe)+strlen(reg[0])+strlen(reg[1])+strlen(reg[2])+spaces] = '\0';
	fwrite(buf,strlen(buf),1,yyout_main);
	free(reg);
}