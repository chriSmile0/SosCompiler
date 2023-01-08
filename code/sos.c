#include "../inc/code_proj.tab.h"
#include "../inc/fct_yacc.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <getopt.h>

#define DATA_SIZE		1024
#define INSTR_SIZE		4096
#define OUTPUT_FOLDER	"out"
#define DEFAULT_FILE	"output.asm"

extern int yylex();

extern char data[DATA_SIZE];
extern char instructions[INSTR_SIZE];
extern char procedures[INSTR_SIZE];
extern int yaccc;

int main(int argc, char *argv[]) {
	static struct option options[] = {
		{"version", no_argument, NULL, 'v'},
		{"tos", no_argument, NULL, 't'},
		{"o", required_argument, NULL, 'o'},
		{"g", no_argument, NULL, 'g'},
		{NULL, 0, NULL, 0}
	};
	
	init_tds();

	int opt, index, flagTds, flagGen = 0;
	char nomFichier[BUFSIZ] = "";
	while ((opt = getopt_long(argc, argv, "vto:g", options, &index)) != -1) {
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
			case 'o': {
				size_t ret = 0;
				ret = snprintf(nomFichier, sizeof(nomFichier), "%s/%s",
					OUTPUT_FOLDER, optarg);

				// Vérifie l'extension du fichier (.s ou .asm [par défaut])
				char* ext;
				if (
					ret < sizeof(nomFichier) &&
					(ext = strrchr(nomFichier, '.')) != NULL
				) {
					if (strcmp(ext,".s") != 0 && strcmp(ext,".asm") != 0)
						ret = snprintf(nomFichier, sizeof(nomFichier), "%s%s",
							nomFichier, ".asm");
				}

				if (ret >= sizeof(nomFichier)) {
					sprintf(nomFichier, "%s/%s", OUTPUT_FOLDER, DEFAULT_FILE);
					fprintf(stderr, "Nom de fichier trop long\n"
						"Usage de \"%s\" à la place\n", nomFichier);
				}
				break;
			}

			case 'g':
				flagGen = 1;
				yaccc = 1;
				break;

			/* Inconnu */
			default:
				return EXIT_FAILURE;
		}
	}

	printf("*** Main ***\n");
	if (flagGen) {
		strcat(data,"\t.data\n");
		strcat(instructions,"\t.text\n__start:\n");
		yyparse();
	}
	else {
		int t;
		while ((t = yylex()) != 0)
			printf("t : %d\n",t);
	}

	if (flagTds == 1) {
		printf("*** Table des symboles ***\n");
		print_tds();
	}

	char code[DATA_SIZE + INSTR_SIZE];
	size_t ret = snprintf(code, sizeof(code), "%s%s\n%s", data, instructions, procedures);
	if (ret >= sizeof(code))
		fprintf(stderr, "Erreur concaténation du code MIPS");
	else if (strlen(nomFichier) > 0) {
		printf("\n*** Fichier de sortie ***\n");

		struct stat st;
		if (stat(OUTPUT_FOLDER, &st) == -1) {
			if (mkdir(OUTPUT_FOLDER, 0755) == -1) {
				perror("Erreur création du dossier de sortie\n");
				exit(EXIT_FAILURE);
			}
		}

		FILE* fd;
		if ((fd = fopen(nomFichier, "w")) == NULL) {
			perror("Erreur ouverture du fichier de sortie\n");
			exit(EXIT_FAILURE);
		}

		size_t ret = fwrite(code, sizeof(char), strlen(code), fd);
		if (ret != strlen(code)) {
			perror("Erreur écriture du fichier de sortie\n");
			exit(EXIT_FAILURE);
		}

		if (fclose(fd) == EOF) {
			perror("Erreur fermeture du fichier de sortie\n");
			exit(EXIT_FAILURE);
		}

		printf("Code MIPS enregistré dans \"%s\"\n", nomFichier);
	}
	else
		printf("*** Code MIPS ***\n%s", code);

	free_tds();
	return EXIT_SUCCESS;
}
