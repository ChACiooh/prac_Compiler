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

/* SIZE is the size of the hash table */
#define SIZE 211

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

/* the list of line numbers of the source 
 * code in which a variable is referenced
 */
typedef struct LineListRec
   { int lineno;
     struct LineListRec * next;
   } * LineList;

/* The record in the bucket lists for
 * each variable, including name, 
 * assigned memory location, and
 * the list of line numbers in which
 * it appears in the source code
 */
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

/* the hash table */
static ScopeList hashTable[SIZE];
//static BucketList hashTable[SIZE];

/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */
void st_insert( char * scope, char * name, ExpType type, int lineno, int loc )
{ int h1 = hash(scope), h2 = hash(name);
  ScopeList sl = hashTable[h];
  BucketList bl = sl->bucket[h2];
  while ((sl != NULL) && (strcmp(scope,sl->name) != 0))
    sl = sl->parent;
  if (sl == NULL)
  {
	  sl = (ScopeList)malloc(sizeof(struct ScopeListRec));
	  sl->name = scope;
	  sl->parent = hashTable[h1];
	  hashTable[h1] = sl;
  }
  // TODO
  Linelist t = sl->bucket[h2]->lines;
  while(t->next != NULL) t = t->next;
  t->next = (LineList)malloc(sizeof(struct LineListRec));
  while ((bl != NULL) && (strcmp(name,bl->name) != 0))
	bl = bl->next;
  if (bl == NULL) /* variable not yet in table */
  { bl = (BucketList) malloc(sizeof(struct BucketListRec));
    bl->name = name;
	bl->type = type;
    bl->lines = (LineList) malloc(sizeof(struct LineListRec));
    bl->lines->lineno = lineno;
    bl->memloc = loc;
    bl->lines->next = NULL;
    bl->next = hashTable[h2];
    hashTable[h2] = bl; }
  else /* found in table, so just add line number */
  { LineList t = l->lines;
    while (t->next != NULL) t = t->next;
    t->next = (LineList) malloc(sizeof(struct LineListRec));
    t->next->lineno = lineno;
    t->next->next = NULL;
  }
} /* st_insert */

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

BucketList st_lookup(char *scope, char *name)
{
	int h = hash(name);
	int k = hash(scope);
	BucketList l = hashTable[h];
	while( (l != NULL) && (strcmp(name, l->name) != 0) )
	{
		l = l->next;
		if(l == NULL)
		{
			l = l->
		}
	}
	return l;
}

/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing)
{ int i;
  fprintf(listing,"Variable Name  Location   Line Numbers\n");
  fprintf(listing,"-------------  --------   ------------\n");
  for (i=0;i<SIZE;++i)
  { if (hashTable[i] != NULL)
    { BucketList l = hashTable[i];
      while (l != NULL)
      { LineList t = l->lines;
        fprintf(listing,"%-14s ",l->name);
        fprintf(listing,"%-8d  ",l->memloc);
        while (t != NULL)
        { fprintf(listing,"%4d ",t->lineno);
          t = t->next;
        }
        fprintf(listing,"\n");
        l = l->next;
      }
    }
  }
} /* printSymTab */
