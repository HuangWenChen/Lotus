CC = gcc
CFLAGS = -std=gnu11 -lfl 
SRCS_flex = Lotus.l
SRCS_bison = Lotus.y
SRCS = Lotus_table.c Lotus.tab.c lex.yy.c
DEPS = Lotus_table.h Lotus.tab.h
EXEC = lotus

TESTDIR = "./test"
TEST := $(shell find $(TESTDIR)/*)

.PHONY: all test
all: Lotus.tab.c Lotus.tab.h lex.yy.c $(EXEC)

Lotus.tab.c Lotus.tab.h: $(SRCS_bison)
	bison -d $<

lex.yy.c: $(SRCS_flex) $(DEPS)
	flex -o $@ $(SRCS_flex)
	
$(EXEC): $(SRCS) $(DEPS)
	$(CC) -o $@ $(SRCS) $(CFLAGS)

test: $(EXEC)
	@for file in $(TEST); do \
		echo "./$(EXEC) <" $$file; \
		./$(EXEC) < $$file && echo; \
	done


.PHONY: clean
clean:
	$(RM) $(EXEC) Lotus.tab.c Lotus.tab.h lex.yy.c
