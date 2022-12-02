dir_bin = bin/
dir_code = code/
dir_docs = docs/
dir_inc = inc/
dir_objs = objs/
dir_test = tests/

prefixe_code = code_proj
prefixe_test = tests_proj

path_code = $(dir_code)$(prefixe_code)
path_doc = $(dir_docs)$(prefixe_code)
path_inc = $(dir_inc)$(prefixe_code)
path_test = $(dir_test)$(prefixe_test)

CC = gcc
CFLAGS = -Wall -Werror -Wextra
LEX = flex
BIS = bison
LXFLAGS = # -d for debug for example # flex flags
BFLAGS = -t -d # bison flags

# exige 3 fichiers:
# - $(prefixe).y (fichier bison)
# - $(prefixe).lex (fichier flex)
# - main.c (programme principal)
# - tests.c (programme de tests en c)
# construit un exécutable nommé "sos"

# note : le programme principal ne doit surtout pas s'appeler $(prefixe).c
# (make l'écraserait parce qu'il a une règle "%.c: %.y")

all: dir lex_bis

lex_bis:
	$(BIS) $(BFLAGS) $(path_code).y -o $(path_inc).tab.c
	$(CC) -c -o $(dir_objs)$(prefixe_code).tab.o $(path_inc).tab.c
	$(LEX) $(LXFLAGS) -o $(dir_code)voc.c $(path_code).lex
	$(CC) -c -o $(dir_objs)voc.o $(dir_code)voc.c
	$(CC) -c -o $(dir_objs)sos.o $(dir_code)sos.c
	$(CC) $(dir_objs)*.tab.o $(dir_objs)voc.o $(dir_objs)sos.o -o \
		$(dir_bin)sos
	$(CC) -c -o $(dir_objs)test.o $(dir_code)test.c
	$(CC) -c -o $(dir_objs)fct_tests.o $(dir_code)fct_tests.c
	$(CC) $(dir_objs)fct_tests.o $(dir_objs)*.tab.o $(dir_objs)voc.o \
		$(dir_objs)test.o -o $(dir_bin)test

dir: # -commande pour ignorer les erreurs de la commande
	-mkdir $(dir_objs) 2> /dev/null
	-mkdir $(dir_bin) 2> /dev/null

doc_m:
	bison --report=all --report-file=$(prefixe_code).output \
		--graph=$(prefixe_code).dot --output=/dev/null \
		$(path_code).y
	dot -Tpdf < $(prefixe_code).dot > $(prefixe_code).pdf
	mv *.pdf docs
	-rm -f *.dot *.output

test: all
	./bin/test $(ARGS)

clean:
	-rm -r $(dir_objs) bin
	-rm -f $(path_code).c $(dir_code)voc.c $(path_inc).tab.* $(path_doc).pdf