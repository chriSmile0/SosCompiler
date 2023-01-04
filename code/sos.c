#include "../inc/code_proj.tab.h"
#include "../inc/fct_yacc.h"
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
extern int yylex();

int main(int argc, char *argv[]) {
	static struct option options[] = {
		{"version", no_argument, NULL, 'v'},
		{"tos", no_argument, NULL, 't'},
		{"o", required_argument, NULL, 'o'},
		{NULL, 0, NULL, 0}
	};
	
	//init_tds();

	int opt, index, flagTds = 0;
	while ((opt = getopt_long(argc, argv, "v:t:o:", options, &index)) != -1) {
		switch (opt) {
			/* Version */
			case 'v':
				printf("*** Membres ***\n");
				printf("Christopher Spitz\n");
				printf("Loïc Diebolt\n");
				printf("Matthieu Lefevre\n");
				printf("Vincent Chebbli-Disdier");
				return EXIT_SUCCESS;

			/* Table des symboles */
			case 't':
                flagTds = 1;
                break;

			/* Fichier de sortie */
			case 'o':
				printf("*** Fichier de sortie ***\n");
				printf("Fichier d'enregistrement : %s\n", optarg);
				break;

			/* Inconnu */
			default:
				return EXIT_FAILURE;
		}
	}

	printf("*** Main ***\n");
	int t;
	while ((t = yylex()) != 0) 
		printf("t : %d\n",t);

	if (flagTds == 1){
        printf("*** Table des symboles ***\n");
        print_tds();
    }
	free_tds();
	return EXIT_SUCCESS;
}