/****************************************************/
/* File: analyze.c                                  */
/* Semantic analyzer implementation                 */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "symtab.h"
#include "analyze.h"
#include "util.h"

/* counter for variable memory locations */
static int location = 0;

/* Procedure traverse is a generic recursive 
 * syntax tree traversal routine:
 * it applies preProc in preorder and postProc 
 * in postorder to tree pointed to by t
 */
static void traverse(TreeNode * t,
               void (* preProc) (TreeNode *),
               void (* postProc) (TreeNode *) )
{ if (t != NULL)
  { preProc(t);
    { int i;
      for (i=0; i < MAXCHILDREN; i++)
        traverse(t->child[i],preProc,postProc);
    }
    postProc(t);
    traverse(t->sibling,preProc,postProc);
  }
}

/* nullProc is a do-nothing procedure to 
 * generate preorder-only or postorder-only
 * traversals from traverse
 */
static void nullProc(TreeNode * t)
{ if (t==NULL) return;
  else return;
}

static void semanticError(TreeNode *t, const char* msg)
{
	fprintf(listing, "Semantic error at line %d: %s\n", t->lineno, msg);
	Error = TRUE;
}

static void insertIOfunc()
{
	TreeNode *prime;
	TreeNode *func;
	TreeNode *param;
	TreeNode *cmpndStmt;

	prime = newPrimeNode();
	prime->attr.name = "input";
	prime->type = Integer;

	cmpndStmt = newStmtNode(CmpndK);
	cmpndStmt->child[0] = NULL;      // no local var
	cmpndStmt->child[1] = NULL;      // no stmt

	func = prime;
	func->nodekind = DclK;
	func->kind.dcl = FdclK;

	func->lineno = 0;
	func->child[0] = param;
	func->child[1] = cmpndStmt;
	st_insert("global", "input", Integer, func->lineno, location++);


	prime = newPrimeNode();
	prime->attr.name = "output";
	prime->type = Void;

	cmpndStmt = newStmtNode(CmpndK);
	cmpndStmt->child[0] = NULL;      // no local var
	cmpndStmt->child[1] = NULL;      // no stmt

	func = prime;
	func->nodekind = DclK;
	func->kind.dcl = FdclK;
	
	param = newPrimeNode();
	param->attr.name = "arg";
	param->is_param = TRUE;
	param->type = Integer;

	func->lineno = 0;
	func->child[0] = param;
	func->child[1] = cmpndStmt;

	st_insert("global", "output", Void, func->lineno, location++);
}

static void setScopes(TreeNode *t)
{
	int i;
	if(t == NULL || t->scope == NULL)	return;
	for(i = 0; i < MAXCHILDREN; ++i)
	{
		t->child[i]->scope = t->scope;
		setScopes(t->child[i]);
	}
}

/* Procedure insertNode inserts 
 * identifiers stored in t into 
 * the symbol table 
 */
static void insertNode(TreeNode * t)
{ 
	if(t == NULL)	return;
	BucketList bl = NULL;
	LineList ll = NULL;
  switch (t->nodekind)
  { 
	  case DclK:
	   switch(t->kind.dcl) {
		  case VdclK:
			  bl = st_lookup(t->scope,t->attr.name);
			  if(bl != NULL)
			  {
				  semanticError(t, "variable already declared.");
				  break;
			  }
			  st_insert(t->scope, t->attr.name, t->type, t->lineno, location++);
			  break;
		  case FdclK:
			  bl = st_lookup_excluding_parent("global",t->attr.name);

			  if(bl != NULL)
			  {
				  semanticError(t, "function was already declared.");
			  }
			  else
			  {
				  st_insert("global", t->attr.name, t->type, t->lineno, location++);
			  }
			  break;
		  default:
			  break;
	  }
	  break;
	 case StmtK:
      switch (t->kind.stmt)
      { 
		  case CmpndK:
			  t->child[0]->scope = t->child[1]->scope = copyString(t->scope);
			  break;
		  case ExpSK:
			  switch(t->kind.exp)
			  {
				  case IdK:
				  case AssignK:
				  case CallK:
					bl = st_lookup(t->scope, t->attr.name);
					if(bl == NULL)
					{
						st_insert(t->scope, t->attr.name, t->type, t->lineno, location++);
						//semanticError(t, "undeclared symbol.");
					}
					else
					{
						/*
						ll = bl->lines;
						while(ll->next != NULL)	ll = ll->next;
						ll->next = (LineList)malloc(sizeof(struct LineListRec));
						ll->next->lineno = lineno;
						ll->next->next = NULL;*/
						st_add_lineno(&bl, lineno);
						//st_insert(t->scope, t->attr.name, t->type, t->lineno, location++);
					}
					break;
				  default:
					break;
			  }
			  break;
		  case RetK:
			  bl = st_lookup(t->scope, t->attr.name);
			  if(bl != NULL)
			  {
				  st_add_lineno(&bl, lineno);
			  }
			  else
			  {
				  st_insert(t->scope, t->attr.name, t->type, t->lineno, location++);
			  }
		  default:
			  break;
      }
      break;
    default:
      break;
  }
}

/* Function buildSymtab constructs the symbol 
 * table by preorder traversal of the syntax tree
 */
void buildSymtab(TreeNode * syntaxTree)
{ 
	insertIOfunc();
	traverse(syntaxTree,setScopes,nullProc);
	traverse(syntaxTree,insertNode,nullProc);
	//printf("Hello\n");
  if (TraceAnalyze)
  { fprintf(listing,"\nSymbol table:\n\n");
    printSymTab(listing);
  }
}

static void typeError(TreeNode * t, char * message)
{ fprintf(listing,"Type error at line %d: %s\n",t->lineno,message);
  Error = TRUE;
}

/* Procedure checkNode performs
 * type checking at a single tree node
 */
static void checkNode(TreeNode * t)
{ switch (t->nodekind)
  { case ExpK:
      switch (t->kind.exp)
      { case OpK:
          if ((t->child[0]->type != Integer) ||
              (t->child[1]->type != Integer))
            typeError(t,"Op applied to non-integer");
          if ((t->attr.op == EQ) || (t->attr.op == LT)
				  || (t->attr.op == LE) || (t->attr.op == GE)
				  || (t->attr.op == GT) || (t->attr.op == NE))
            t->type = Boolean;
          else
            t->type = Integer;
          break;
        case AssignK:
		  /* TODO : this is for semantics. */
          break;
		/* TODO : case of ParenK, CallK need to be implemented. */
		case ConstK:
        case IdK:
          t->type = Integer;
          break;
        default:
          break;
      }
      break;
    case StmtK:
      switch (t->kind.stmt)
      { case IfK:
          if (t->child[0]->type == Integer)
            typeError(t->child[0],"if test is not Boolean");
          break;
        case WhileK:
          if (t->child[0]->type == Integer)
            typeError(t->child[0],"if test is not Boolean");
          break;
        case ExpSK:
          if (t->child[0]->type != Integer)
            typeError(t->child[0],"write of non-integer value");
          break;
        case CmpndK:
          if (t->child[1]->type == Integer)
            typeError(t->child[1],"repeat test is not Boolean");
          break;
		case RetK:
		  if (t->child[0]->type != Integer)
			typeError(t->child[0],"return of on-integer value");
        default:
          break;
      }
      break;
    default:
      break;

  }
}

/* Procedure typeCheck performs type checking 
 * by a postorder syntax tree traversal
 */
void typeCheck(TreeNode * syntaxTree)
{ traverse(syntaxTree,nullProc,checkNode);
}
