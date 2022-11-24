#include "../inc/code_proj.tab.h"
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

	int opt, index = 0;
	while ((opt = getopt_long(argc, argv, "v:t:o:", options, &index)) != -1) {
		switch (opt) {
			/* Version */
			case 'v':
				printf("*** Membres ***\n");
				printf("Christopher Spitz\n");
				printf("Loïc Diebolt\n");
				printf("Matthieu Lefevre\n");
				printf("Vincent Chebbli-Disdier");
				break;

			/* Table des symboles */
			case 't':
				printf("*** Table des symboles ***\n");
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

	return EXIT_SUCCESS;
}