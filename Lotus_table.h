#ifndef _LOTUS_TABLE_H_
#define _LOTUS_TABLE_H_

#define TABLESIZE	7

typedef struct __KEYWORD{
    char *str;
    int token;
    struct __KEYWORD *next;
}keyword;

typedef struct __KEYWORD_HASH_TABLE{
    keyword **list;
}hashTable;

keyword *findKeyword(char *kw, hashTable *ht);
hashTable *createHashTable();
void append(char *kw, int token, hashTable *ht);
unsigned int BKDRHash(char *str);

int install_integer();
void error_handle();

#endif
