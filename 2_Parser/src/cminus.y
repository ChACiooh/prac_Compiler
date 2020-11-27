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
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void); // added 11/2/11 to ensure no conflict with lex

%}

%token IF ELSE RETURN WHILE INT VOID 
%token ID NUM 
%right TIMES OVER
%right PLUS MINUS
%right EQ NE LT LE GT GE
%right ASSIGN LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY SEMI COMMA
%token ERROR 

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
			| ERROR { $$ = NULL; }
			;
var_dcl		: type_spec ID { 
				  savedName = copyString(tokenString);
				  savedLineNo = lineno;
			  } SEMI
				{ 
					$$ = newDclNode(VdclK);
					$$->type = $1;
					$$->attr.name = savedName;
					$$->lineno = savedLineNo;
				}
			| type_spec ID { 
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			  }LBRACE NUM RBRACE SEMI
				{
					$$ = newDclNode(VdclK);
					$$->type = $1;
					$$->attr.name = $2;
					$$->arr_size = $4;
					$$->lineno = savedLineNo;
				}
			;
type_spec	: INT { $$ = Integer; }
			| VOID { $$ = Void; }
			| ERROR {
				yyerror("Invalid type error.");
				$$ = NULL;
				}
			;
fun_dcl		: type_spec ID {
				  savedName = copyString(tokenString);
				  savedLineNo = lineno;
			  } LPAREN params RPAREN cmpnd_stmt
				{
					$$ = newDclNode(FdclK);
					$$->type = $1;
					$$->attr.name = savedName;
					$$->child[0] = $5;
					$$->child[1] = $7;
					$$->lineno = svedLineNo;
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
					}
				}
			| param { $$ = $1; }
			;
param		: type_spec ID
				{
					$$ = newExpNode(Idk);
					$$->type = $1;
					$$->attr.name = copyString(tokenString);
					$$->is_param = TRUE;
					$$->lineno = lineno;
				}
			| type_spec ID { 
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			} LBRACE RBRACE
				{
					$$ = newExpNode(IdK);
					$$->type = $1;
					$$->attr.name = $2;
					$$->is_param = TRUE;
					$$->lineno = savedLineNo;
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
stmt_list   : stmt_list SEMI stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; 
				   } else {
					   yyerror("statement needed before ';'");
					   $$ = NULL;
				   }
                 }
            | stmt  { $$ = $1; }
			| /* empty */
            ;
stmt        : select_stmt { $$ = $1; }
			| ns_stmt { $$ = $1; }
			| ERROR { $$ = NULL; }
            ;
ns_stmt		: exp_stmt { $$ = $1;}
			| cmpnd_stmt { $$ = $1; }
			| iter_stmt { $$ = $1; }
			| return_stmt { $$ = $1; }
			;
exp_stmt	: exp SEMI { $$ = $1; }
			| SEMI { $$ = NULL; }
			;
select_stmt : IF LPAREN exp RPAREN stmt
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
            | IF LPAREN exp RPAREN ns_stmt ELSE stmt
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
				  $$->attr.name = copyString(tokenString);
				  $$->lineno = lineno;
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
relop		: LE { $$ = LE; }
			| LT { $$ = LT; }
			| GT { $$ = GT; }
			| GE { $$ = GE; }
			| EQ { $$ = EQ; }
			| NE { $$ = NE; }
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
addop		: PLUS { $$ = PLUS; } | MINUS { $$ = MINUS; }
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
mulop		: TIMES { $$ = TIMES; } | OVER { $$ = OVER; }
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
				   savedLineno = lineno;
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
					  al->sibling =- $3;
					  $$ = al;
				  } else { 
					  yyerror("Function-call needs an argument before ','"); 
					  $$ = NULL;  
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

