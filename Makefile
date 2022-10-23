dir_t=tests/
dir_c=code/
dir_d=docs/
prefixe_t=tests_proj
prefixe_c=code_proj
obj=objs/
inc=inc/
bin=bin/
path_c=$(dir_c)$(prefixe_c)
path_t=$(dir_t)$(prefixe_t)
path_d=$(dir_d)$(prefixe_c)
path_inc=$(inc)/$(prefixe_c)

CC=gcc
CFLAGS= -Wall -Werror -Wextra
LEX=flex
BIS=bison
LXFLAGS= # -d for debug for example // flexflags
BFLAGS = -t -d # bison flags

# exige 3 fichiers:
# - $(prefixe).y (fichier bison)
# - $(prefixe).lex (fichier flex)
# - main.c (programme principal)
# - tests.c (programme de tests en c)
# construit un exécutable nommé "main"

# note : le programme principal ne doit surtout pas s'appeler $(prefixe).c
# (make l'écraserait parce qu'il a une règle "%.c: %.y")

all: dir lex_bis

lex_bis: 
	$(BIS) $(BFLAGS) $(path_c).y -o $(path_inc).tab.c
	$(CC) -c -o $(obj)$(prefixe_c).tab.o $(path_inc).tab.c
	$(LEX) $(LXFLAGS) -o $(dir_c)voc.c $(path_c).lex 
	$(CC) -c -o $(obj)voc.o $(dir_c)voc.c
	$(CC) -c -o $(obj)main.o $(dir_c)main.c
	$(CC) $(obj)*.tab.o $(obj)voc.o $(obj)main.o -o $(bin)main 
	$(CC) -c -o $(obj)test.o $(dir_c)test.c
	$(CC) $(dir_c)fct_tests.c $(inc)fct_tests.h  \
		$(obj)*.tab.o $(obj)voc.o $(obj)test.o -o $(bin)test

dir: # -commande pour ignorer les erreurs de la commande
	-mkdir objs 2> /dev/null
	-mkdir bin 2> /dev/null

	
doc_m:
	bison --report=all --report-file=$(prefixe_c).output \
		--graph=$(prefixe_c).dot --output=/dev/null \
		$(path_c).y 
	dot -Tpdf < $(prefixe_c).dot > $(prefixe_c).pdf
	mv *.pdf docs 
	-rm -f *.dot *.output

test:
	./bin/test $(ARGS) 

clean:
	-rm -r objs bin
	-rm -f $(path_c).c $(dir_c)voc.c $(path_inc).tab.* $(path_d).pdf