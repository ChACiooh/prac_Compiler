/****************************************************/
/* File: symtab.c                                   */
/* Symbol table implementation for the TINY compiler*/
/* (allows only one symbol table)                   */
/* Symbol table is implemented as a chained         */
/* hash table                                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"


/* SHIFT is the power of two used as multiplier
   in hash function  */
#define SHIFT 4

/* the hash function */
static int hash ( char * key )
{ int temp = 0;
  int i = 0;
  while (key[i] != '\0')
  { temp = ((temp << SHIFT) + key[i]) % SIZE;
    ++i;
  }
  return temp;
}

/* The record in the bucket lists for
 * each variable, including name, 
 * assigned memory location, and
 * the list of line numbers in which
 * it appears in the source code
 */

/* the hash table */
//static BucketList hashTable[SIZE];

/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */
void st_insert( char * scope, char * name, ExpType type, int lineno, int loc )
{ int h1 = hash(scope), h2 = hash(name);
  ScopeList sl = hashTable[h1];

  while ((sl != NULL) && (strcmp(scope,sl->name) != 0))
    sl = sl->parent;
  if (sl == NULL)
  {
	  sl = (ScopeList)malloc(sizeof(struct ScopeListRec));
	  sl->name = scope;
	  sl->parent = hashTable[h1];
	  hashTable[h1] = sl;
  }
  
  /* found scope or inserted new scope */
  BucketList bl = sl->bucket[h2];
  while((bl != NULL) && (strcmp(name, bl->name) != 0))
	  bl = bl->next;
  if (bl == NULL) /* variable not yet in table */
  { bl = (BucketList) malloc(sizeof(struct BucketListRec));
    bl->name = name;
	bl->type = type;
    bl->lines = (LineList) malloc(sizeof(struct LineListRec));
    bl->lines->lineno = lineno;
    bl->memloc = loc;
    bl->lines->next = NULL;
    bl->next = sl->bucket[h2];
    sl->bucket[h2] = bl; 
  }
  else
  {
	 st_add_lineno(&bl, lineno);
  }
} /* st_insert */

void st_add_lineno(BucketList *blp, int lineno)
{
	//printf("add lineno\n");
	BucketList bl = *blp;
	LineList t = bl->lines;
	while(t->next != NULL) t = t->next;
	t->next = (LineList) malloc(sizeof(struct LineListRec));
	t->next->lineno = lineno;
    t->next->next = NULL;
}

/* Function st_lookup returns the memory 
 * location of a variable or -1 if not found
 *
int st_lookup ( char * scope, char * name )
{ int h = hash(name);
  BucketList l =  hashTable[h];
  while ((l != NULL) && (strcmp(name,l->name) != 0))
    l = l->next;
  if (l == NULL) return -1;
  else return l->memloc;
}
 */

/* Function st_lookup returns the memory
 * if it doesn't exist, returns NULL
 */
BucketList st_lookup(char *scope, char *name)
{
	int h1, h2;
	h1 = hash(scope);
	h2 = hash(name);
	ScopeList sl = hashTable[h1];
	BucketList bl = NULL;
	while( (sl != NULL) && (strcmp(scope, sl->name) != 0) )
		sl = sl->parent;
	if(sl != NULL)
	{
		bl = sl->bucket[h2];
		while((bl != NULL) && (strcmp(name, bl->name) != 0))
			bl = bl->next;
	}
	return bl;
}

BucketList st_lookup_excluding_parent(char *scope, char *name)
{
	BucketList bl = NULL;
	int h1 = hash(scope), h2 = hash(name);
	ScopeList sl = hashTable[h1];
	if(sl != NULL && (strcmp(scope, sl->name)) == 0)
	{
		bl = sl->bucket[h2];
		while((bl != NULL) && (strcmp(name, bl->name) != 0))
			bl = bl->next;
	}
	return bl;
}

/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing)
{ 
	int i,j;
	BucketList bl = NULL;
    for (i=0;i<SIZE;++i)
    { 
	  ScopeList sl = hashTable[i];
	  while (sl != NULL)
      { 
		fprintf(listing,"\n");
		fprintf(listing,"Name           type     Scope Name  Location   Line Numbers\n");
		fprintf(listing,"-------------  -------  ----------  --------   ------------\n");

		for(j=0;j<SIZE;++j)
		{
			bl = sl->bucket[j];
			while(bl != NULL){
				fprintf(listing,"%-14s ", bl->name);
				switch(bl->type)
				{
					case Integer:
						fprintf(listing,"%-8s ", "int");
						break;
					case IntArr:
						fprintf(listing,"%-8s ", "int[]");
						break;
					case Void:
						fprintf(listing,"%-8s ", "void");
						break;
					default:
						break;
				}
				fprintf(listing,"%-11s ", sl->name);
				fprintf(listing,"%-6d  ", bl->memloc);

				LineList t = bl->lines;
				while(t != NULL)
				{
					fprintf(listing,"%4d ", t->lineno);
					t = t->next;
				}
				fprintf(listing, "\n");
				bl = bl->next;
			}
		 }
		 sl = sl->parent;
	  }
  }
} /* printSymTab */
