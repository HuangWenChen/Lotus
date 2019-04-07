#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Lotus_table.h"

extern char *yytext;
extern int yylineno;

keyword *findKeyword(char *kw, hashTable *ht){
	keyword *k;
	unsigned int index = BKDRHash(kw);
    
    for(k = ht->list[index]; k; k = k->next){
        if(!strcmp(kw, k->str)) 
            return k;
    }
    return NULL;
}

void append(char *kw, int token, hashTable *ht){
    unsigned int index = BKDRHash(kw);
    keyword *k = (keyword*)malloc(sizeof(keyword));
    k->str = kw;
    k->token = token;
    k->next = ht->list[index];
    ht->list[index] = k;
}

hashTable *createHashTable(){
    hashTable *ht;
    ht = (hashTable*)malloc(sizeof(hashTable));
    ht->list = (keyword**)malloc(sizeof(keyword*)*TABLESIZE);

    for(int i = 0; i < TABLESIZE; i++){
        ht->list[i] = NULL;
    }
    return ht;
}

unsigned int BKDRHash(char *str){
	unsigned int seed = 131;
	unsigned int hash = 0;
	
	while(*str){
		hash = hash * seed + (*str++);
	}
	return (hash % TABLESIZE);
}

int install_integer(){
    return atoi(yytext);
}

void error_handle(){
    fprintf(stderr, "Lexical error: line %d: unknown character %c\n", yylineno, yytext[0]);
}

