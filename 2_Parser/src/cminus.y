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

var_dcl		: nv_dcl SEMI | arr_dcl SEMI;
prim_dcl	: INT ID {
				  /* int a */
				  $$ = newDclNode(VdclK);
				  $$->attr.name = copyString(tokenString);
				  $$->type = Integer;
				  $$->lineno = lineno;
			  }
			| VOID ID {
				  /* void a */
				  $$ = newDclNode(VdclK);
				  $$->attr.name = copyString(tokenString);
				  $$->type = Void;
				  $$->lineno = lineno;
			  }
nv_dcl		: prim_dcl {$$=$1;}
			;
arr_dcl		: prim_dcl LBRACE NUM { savedVal = atoi(tokenString); } RBRACE {
				  /* void arr */
				  $$ = $1;
				  $$->arr_size = savedVal;
			  }
			;
type_spec	: INT | VOID
			;
fun_dcl		: type_spec ID { savedName = copyString(tokenString); }
			  LPAREN params RPAREN cmpnd_stmt
				{
					$$ = newDclNode(FdclK);
					if($1 == INT)
						$$->type = Integer;
					else if($1 == VOID)
						$$->type = Void;
					$$->attr.name = copyString(savedName);
					$$->child[0] = $5;
					$$->child[1] = $7;
					$$->lineno = lineno;
				}
			;
params		: param_list { $$ = $1; }
			| VOID { /* empty */ }
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
param		: type_spec ID
				{
					$$ = newExpNode(IdK);
					if($1 == INT)
						$$->type = Integer;
					else if($1 == VOID)
						$$->type = Void;
					else
					{
						if($$ != NULL) {
							free($$);
							$$ = NULL;
						}
						yyerror("invalid type error");
						exit(1);
					}
					$$->attr.name = copyString(tokenString);
					$$->is_param = TRUE;
					$$->lineno = lineno;
				}
			| type_spec ID { 
				savedName = copyString(tokenString);
			} LBRACE RBRACE
				{
					$$ = newExpNode(IdK);
					$$->type = Integer;
					
					$$->attr.name = savedName;
					$$->is_param = TRUE;
					$$->lineno = lineno;
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
			| /* empty */ 
			;
stmt_list   : stmt_list_ { $$ = $1; }	
			| /* empty */
            ;
stmt_list_	: stmt_list_ stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; 
				   } else {
					   yyerror("statement needed before ';'");
					   $$ = NULL;
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
exp_stmt	: exp SEMI { $$ = $1; }
			| SEMI
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
                   $$->child[2] = $6;
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
var			: ID 
				{ $$ = newExpNode(IdK);
				  $$->attr.name = copyString(tokenString);
				  $$->lineno = lineno;
				}
			| ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
				LBRACE exp RBRACE
				{ $$ = newExpNode(IdK);
				  $$->child[0] = $4;
				  $$->attr.name = savedName;
				  $$->lineno = savedLineNo;
				}
			;
simple_exp	: addt_exp relop addt_exp
				{
					$$ = newExpNode(OpK);
					$$->child[0] = $1;
					$$->attr.op = $2;
					$$->child[1] = $3;
				}
			| addt_exp { $$ = $1; }
			;
relop		: LE | LT | GT | GE | EQ | NE  
			; 
addt_exp	: addt_exp addop term
				{
					$$ = newExpNode(OpK);
					$$->child[0] = $1;
					$$->attr.op = $2;
					$$->child[1] = $3;
				}
			| term { $$ = $1; }
			;
addop		: PLUS | MINUS 
			;
term		: term mulop factor
				{
					$$ = newExpNode(OpK);
					$$->child[0] = $1;
					$$->child[1] = $3;
					$$->attr.op = $2;
				}
			| factor { $$ = $1; }
			;
mulop		: TIMES | OVER
			;
factor		: LPAREN exp RPAREN
				{ $$ = newExpNode(ParenK); 
				  $$->child[0] = $2;
				}
			| var { $$ = $1; }
			| call { $$ = $1; }
			| NUM { $$ = NUM; }
			;
call		: ID { savedName = copyString(tokenString);
				   savedLineNo = lineno;
			  } LPAREN args RPAREN
				{
					$$ = newExpNode(CallK);
					$$->attr.name = savedName;
					$$->child[0] = $4;
				}
			;
args		: arg_list { $$ = $1; }
			| /* empty */
			;
arg_list	: arg_list COMMA exp
				{ YYSTYPE al = $1;
				  if (al != NULL)
				  {
					  while(al->sibling != NULL)
						  al = al->sibling;
					  al->sibling = $3;
					  $$ = al;
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
