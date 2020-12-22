/****************************************************/
/* File: symtab.h                                   */
/* Symbol table interface for the TINY compiler     */
/* (allows only one symbol table)                   */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

#include "globals.h"
/* SIZE is the size of the hash table */
#define SIZE 211
/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */

/* the list of line numbers of the source 
 * code in which a variable is referenced
 */
typedef struct LineListRec
   { int lineno;
     struct LineListRec * next;
   } * LineList;

typedef struct BucketListRec
   { char * name;
	 ExpType type;
     LineList lines;
     int memloc ; /* memory location for variable */
     struct BucketListRec * next;
   } * BucketList;

typedef struct ScopeListRec
  { char * name;
	BucketList bucket[SIZE];
	struct ScopeListRec *parent;
  } * ScopeList;

static ScopeList hashTable[SIZE];

static int hash ( char* );

void st_insert( char * scope, char * name, ExpType type, int lineno, int loc );
void st_add_lineno(BucketList *blp, int lineno);

/* Function st_lookup returns the memory 
 * location of a variable or -1 if not found
 */
//int st_lookup ( char * scope, char * name );

BucketList st_lookup( char * scope, char * name);

BucketList st_lookup_excluding_parent( char * scope, char * name);

/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing);

#endif
