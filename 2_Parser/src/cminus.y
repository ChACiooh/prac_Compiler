/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static int savedVal;
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void); // added 11/2/11 to ensure no conflict with lex
static void assert(YYSTYPE, int);

%}

%token IF ELSE RETURN WHILE INT VOID 
%left PLUS MINUS
%left TIMES OVER
%token EQ NE LT LE GT GE
%token ASSIGN LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY SEMI COMMA
%token ID NUM 
%token ERROR 

%nonassoc IFX
%nonassoc ELSE

%% /* Grammar for C-Minus */

program     : dcl_list { savedTree = $1;} 
            ;
dcl_list	: dcl_list dcl
				{ YYSTYPE t = $1;
				  if (t != NULL)
				  {
					  while (t->sibling != NULL)
						  t = t->sibling;
					  t->sibling = $2;
					  $$ = $1;
				  } else $$ = $2;
				}
			| dcl { $$ = $1; }
			;
dcl			: var_dcl { $$ = $1; }
			| fun_dcl { $$ = $1; }
			;

var_dcl		: nv_dcl SEMI	{$$ = $1;}
			| arr_dcl SEMI	{$$ = $1;}
			;
prim_dcl	: INT ID {
				  /* int a */
				  $$ = newPrimeNode();
				  $$->attr.name = copyString(tokenString);
				  $$->type = Integer;
			  }
			| VOID ID {
				  /* void a */
				  $$ = newPrimeNode();
				  $$->attr.name = copyString(tokenString);
				  $$->type = Void;
			  }
nv_dcl		: prim_dcl {
				  $$ = $1;
				  $$->nodekind = DclK;
				  $$->kind.dcl = VdclK;
			  }
			;
lbr_num		: LBRACE NUM {
				  $$ = newDclNode(VdclK);
				  $$->arr_size = atoi(tokenString);
			  }
			;
arr_dcl		: prim_dcl lbr_num RBRACE {
				  $$ = $1;
				  $$->child[0] = $2;
				  $$->nodekind = DclK;
				  $$->kind.dcl = VdclK;
				  $$->type = IntArr;
			  }
			;
fun_dcl		: prim_dcl LPAREN params RPAREN cmpnd_stmt
				{
					$$ = $1;
					$$->nodekind = DclK;
					$$->kind.dcl = FdclK;
					$$->child[0] = $3;
					$$->child[1] = $5;
				}
			;
params		: param_list { $$ = $1; }
			| VOID { 
					$$ = newPrimeNode();
					$$->is_param = TRUE;
				}
			;
param_list	: param_list COMMA param
				{
					YYSTYPE pl = $1;
					if (pl != NULL)
					{
						while(pl->sibling != NULL)
							pl = pl->sibling;
						pl->sibling = $3;
						$$ = $1;
					} else {
						yyerror("Function needs a parameter before ','");
						$$ = NULL;
						exit(1);
					}
				}
			| param { $$ = $1; }
			;
param		: prim_dcl {
				  $$ = $1; 
				  $$->is_param = TRUE; 
			  }
			| prim_dcl LBRACE RBRACE {
					$$ = $1;
					$$->is_param = TRUE;
					$$->arr_size = 0;	// don't know the size
				}
			;
cmpnd_stmt	: LCURLY local_dcls stmt_list RCURLY
				{
					$$ = newStmtNode(CmpndK);
					$$->child[0] = $2;
					$$->child[1] = $3;
				}
			;
local_dcls	: local_dcls var_dcl
				{
					YYSTYPE t = $1;
					if (t != NULL)
					{
						while(t->sibling != NULL)
							t = t->sibling;
						t->sibling = $2;
						$$ = $1;
					} else $$ = $2;
				}
			| { $$ = NULL; }
			;
stmt_list   : stmt_list_ { $$ = $1; }	
			| { $$ = NULL; }
            ;
stmt_list_	: stmt_list_ stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; 
				   }
                 }
			| stmt { $$ = $1; }
			;
stmt        : select_stmt { $$ = $1; }
			| exp_stmt { $$ = $1;}
			| cmpnd_stmt { $$ = $1; }
			| iter_stmt { $$ = $1; }
			| return_stmt { $$ = $1; }
			;
exp_stmt	: exp SEMI { 
				  $$ = newStmtNode(ExpSK);
				  $$->child[0] = $1;
			  }
			| SEMI {
				$$ = newStmtNode(ExpSK);
				/* empty statement */
			}
			;
select_stmt : IF LPAREN exp RPAREN stmt 
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 } %prec IFX
            | IF LPAREN exp RPAREN stmt ELSE stmt
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                   $$->child[2] = $7;
                 }
            ;
iter_stmt	: WHILE LPAREN exp RPAREN stmt
				{ $$ = newStmtNode(WhileK);
				  $$->child[0] = $3;
				  $$->child[1] = $5;
				}
			;
return_stmt	: RETURN SEMI
				{ $$ = newStmtNode(RetK);
				}
			| RETURN exp SEMI
				{ $$ = newStmtNode(RetK); 
				  $$->child[0] = $2;
				}
			;
exp			: var ASSIGN exp
				{ $$ = newExpNode(AssignK);
				  $$->child[0] = $1;
				  $$->attr.op = ASSIGN;
				  $$->child[1] = $3;
				}
			| simple_exp
				{ $$ = $1; }
			;
id_var		: ID { 
				  $$ = newExpNode(IdK);
				  $$->attr.name = copyString(tokenString);
				}
			;
var			: id_var { $$ = $1; } 
			| id_var LBRACE exp RBRACE
				{ $$ = $1;
				  $$->child[0] = $3;
				}
			;
simple_exp	: addt_exp relop addt_exp
				{
					$$ = $2;
					$$->child[0] = $1;
					$$->child[1] = $3;
				}
			| addt_exp { 
					$$ = $1; 
				}
			;
relop		: LE { $$ = newExpNode(OpK); $$->attr.op = LE; }
			| LT { $$ = newExpNode(OpK); $$->attr.op = LT; }
			| GT { $$ = newExpNode(OpK); $$->attr.op = GT; }
			| GE { $$ = newExpNode(OpK); $$->attr.op = GE; }
			| EQ { $$ = newExpNode(OpK); $$->attr.op = EQ; }
			| NE { $$ = newExpNode(OpK); $$->attr.op = NE; }
			; 
addt_exp	: addt_exp addop term
				{
					$$ = $2;
					$$->child[0] = $1;
					$$->child[1] = $3;
				}
			| term { $$ = $1; }
			;
addop		: PLUS { $$ = newExpNode(OpK); $$->attr.op = PLUS; }
			| MINUS { $$ = newExpNode(OpK); $$->attr.op = MINUS; } 
			;
term		: term mulop factor
				{
					$$ = $2;
					$$->child[0] = $1;
					$$->child[1] = $3;
				}
			| factor { $$ = $1; }
			;
mulop		: TIMES { $$ = newExpNode(OpK); $$->attr.op = TIMES; }
			| OVER { $$ = newExpNode(OpK); $$->attr.op = OVER; }
			;
factor		: LPAREN exp RPAREN
				{ $$ = newExpNode(ParenK); 
				  $$->child[0] = $2;
				}
			| var { $$ = $1; }
			| call { $$ = $1; }
			| NUM { $$ = newExpNode(ConstK); $$->attr.val = atoi(tokenString); }
			;
call		: id_var LPAREN args RPAREN
				{
					$$ = $1;
					$$->nodekind = ExpK;
					$$->kind.exp = CallK;
					$$->child[0] = $3;
				}
			;
args		: arg_list { $$ = $1; }
			| { $$ = NULL; }
			;
arg_list	: arg_list COMMA exp
				{ YYSTYPE al = $1;
				  if (al != NULL)
				  {
					  while(al->sibling != NULL)
						  al = al->sibling;
					  al->sibling = $3;
					  $$ = $1;
				  } else { 
					  yyerror("Function-call needs an argument before ','"); 
					  $$ = NULL;  
					  exit(1);
				  }
				}
			| exp { $$ = $1; }
			;

/* user implementation ended. */

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

static void assert(YYSTYPE v, int k)
{
	if(k == 0)
	{
		if(v != NULL) {
			free(v);
			v = NULL;
		}
		exit(1);
	}
}
