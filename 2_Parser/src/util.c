/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "util.h"

/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { case IF:
    case ELSE:
	case WHILE:
	case RETURN:
	case INT:
	case VOID:
      fprintf(listing,
         "reserved word: %s\n",tokenString);
      break;
    case ASSIGN: fprintf(listing,"=\n"); break;
    case EQ: fprintf(listing,"==\n"); break;
    case NE: fprintf(listing,"!=\n"); break;
    case LT: fprintf(listing,"<\n"); break;
    case LE: fprintf(listing,"<=\n"); break;
    case GT: fprintf(listing,">\n"); break;
    case GE: fprintf(listing,">=\n"); break;
    case LPAREN: fprintf(listing,"(\n"); break;
    case RPAREN: fprintf(listing,")\n"); break;
    case LBRACE: fprintf(listing,"[\n"); break;
    case RBRACE: fprintf(listing,"]\n"); break;
    case RCURLY: fprintf(listing,"}\n"); break;
    case LCURLY: fprintf(listing,"{\n"); break;
    case SEMI: fprintf(listing,";\n"); break;
	case COMMA: fprintf(listing,",\n"); break;
    case PLUS: fprintf(listing,"+\n"); break;
    case MINUS: fprintf(listing,"-\n"); break;
    case TIMES: fprintf(listing,"*\n"); break;
    case OVER: fprintf(listing,"/\n"); break;
    case ENDFILE: fprintf(listing,"EOF\n"); break;
    case NUM:
      fprintf(listing,
          "NUM, val= %s\n",tokenString);
      break;
    case ID:
      fprintf(listing,
          "ID, name= %s\n",tokenString);
      break;
    case ERROR:
      fprintf(listing,
          "ERROR: %s\n",tokenString);
      break;
    default: /* should never happen */
      fprintf(listing,"Unknown token: %d\n",token);
  }
}

/* Function newTypeNode creates a new declaration
 * node for syntax tree construction
 */
TreeNode * newTypeNode(DclKind kind, ExpType et)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if(t==NULL)
	fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = DclK;
    t->kind.dcl = kind;
    t->lineno = lineno;
	t->is_param = FALSE;
	t->arr_size = -1;
	t->type = et;
  }
  return t;
}

/* Function newDclNode creates a new declaration
 * node for syntax tree construction
 */
TreeNode * newDclNode(DclKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = DclK;
    t->kind.dcl = kind;
    t->lineno = lineno;
	t->is_param = FALSE;
	t->arr_size = -1;
  }
  return t;
}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    t->lineno = lineno;
	t->is_param = FALSE;
	t->arr_size = -1;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = Void;
	t->is_param = FALSE;
	t->arr_size = -1;	// it is not array basically.
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    fprintf(listing," ");
}

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
	if (tree->nodekind==DclK)
	{ switch (tree->kind.dcl) {
		case VdclK:
			fprintf(listing,"Var declaration, name : %s, type : ",tree->attr.name);
			if(tree->type == Integer)
				fprintf(listing,"int\n");
			else if(tree->type == Void)
				fprintf(listing,"void\n");
			else
				fprintf(listing,"unknown type\n");
			break;
		case FdclK:
			fprintf(listing,"Function declaration: %s\n",tree->attr.name);
			INDENT;
			struct treeNode * t = tree->child[0];
			if(t != NULL)
			{
				while(t != NULL) {
					if(t->arr_size == -1) 
						fprintf(listing,"Single parameter, name : %s, type : ",t->attr.name);
					else
						fprintf(listing,"Array parameter, name : %s, type : ",t->attr.name);
					if(t->type == Integer)
						fprintf(listing,"int\n");
					else
						fprintf(listing,"void\n");
					t = t->sibling;
				}
			}
			UNINDENT;
			break;
		default:
			fprintf(listing,"Unknown DclNode kind\n");
			break;
		}
	}
	else if (tree->nodekind==StmtK)
    { switch (tree->kind.stmt) {
        case IfK:
          fprintf(listing,"If\n");
          break;
        case WhileK:
          fprintf(listing,"While\n");
          break;
		case ExpSK:
		  fprintf(listing,"Expression to: %s\n",tree->attr.name);
		  break;
		case CmpndK:
		  fprintf(listing,"Compound\n");
		  break;
		case RetK:
		  fprintf(listing,"Return\n");
		  break;
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind==ExpK)
    { switch (tree->kind.exp) {
        case OpK:
          fprintf(listing,"Op: ");
          printToken(tree->attr.op,"\0");
          break;
        case ConstK:
          fprintf(listing,"Const: %d\n",tree->attr.val);
          break;
        case IdK:
          fprintf(listing,"Id: %s\n",tree->attr.name);
          break;
        case AssignK:
          fprintf(listing,"Assign to: %s\n",tree->child[0]->attr.name);
          break;
		case ParenK:
		  fprintf(listing,"Paren factor\n");
		  break;
		case CallK:
		  fprintf(listing,"Call: %s\n",tree->attr.name);
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else fprintf(listing,"Unknown node kind\n");
    for (i=0;i<MAXCHILDREN;i++)
         printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
