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

ID			: { $$ = newExpNode(IdK);
				$$->attr.name = copyString(tokenString); }
			;
NUM			: { $$ = newExpNode(ConstK);
				$$->attr.val = atoi(tokenString); }
			;

program     : dcl_list
                { savedTree = $1;} 
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
			| error	{ $$ = NULL; }
			;
var_dcl		: type_spec ID SEMI
				{ 
					$$ = newExpNode(IdK);
					if ($1 == INT) { $$->type = Integer; }
					else if ($1 == VOID) { $$->type = Void; }
					$$->attr.name = $2;

				}
			| type_spec ID LBRACE NUM RBRACE SEMI
				{
					$$ = newExpNode(IdK);
					if ($1 == INT) { $$->type = Integer; }
					else if ($1 == VOID) { $$->type = Void; }
					$$->attr.name = $2;
					$$->arr_size = $4;
				}
			;
type_spec	: INT { $$ = INT; }
			| VOID { $$ = VOID; }
			;
fun_dcl		: type_spec ID LPAREN params RPAREN cmpnd_stmt
				{
					YYSTYPE fdcl = $$; // need to make new~~
					if ($1 == VOID) { fdcl->type = Void; }
					else if ($1 == INT) { fdcl->type = Integer; }
					fdcl->attr.name = $2;
					fdcl->child[0] = $4;
					fdcl->child[1] = $6;
				}
			;
params		: param_list | VOID
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
					} else $$ = $3;
				}
			| param { $$ = $1; }
			;
param		: type_spec ID
				{
					$$ = newExpNode(Idk);
					if ($1 == INT) { $$->type = Integer; }
					else if ($1 == VOID) { $$->type = Void; }
					$$->attr.name = $2;
					$$->is_param = TRUE;
				}
			| type_spec ID LBRACE RBRACE
			;
cmpnd_stmt	: LCURLY local_dcls stmt_seq RCURLY
			;
local_dcls	: local_dcls vardcl
			| /* empty */
			;
stmt_list   : stmt_list SEMI stmt
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                     else $$ = $3;
                 }
            | stmt  { $$ = $1; }
			| /* empty */
            ;
stmt        : select_stmt { $$ = $1; }
			| exp_stmt { $$ = $1; }
			| cmpnd_stmt { $$ = $1; }
			| iter_stmt { $$ = $1; }
			| return_stmt { $$ = $1; }
            ;
exp_stmt	: exp SEMI
				{ $$ = $1; }
			| SEMI
			;
select_stmt : IF LPAREN exp RPAREN stmt
                 { $$ = newStmtNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
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
				{ $$ = NULL; }
			| RETURN exp SEMI
				{ $$ = $1; }
			;
exp			: var ASSIGN exp
				{ $$->child[0] = $1;
				  $$->child[1] = $3;
				  $$->attr.name = savedName;
				  $$->lineno = savedLineNo;
				}
			| simple_exp
				{ $$ = $1; }
			;
var			: ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
			| ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
				LBRACE exp RBRACE
				{ /* TODO */ }
			;
simple_exp	: addt_exp relop addt_exp
			| addt_exp
			;
relop		: LE { $$ = LE; }
			| LT { $$ = LT; }
			| GT { $$ = GT; }
			| GE { $$ = GE; }
			| EQ { $$ = EQ; }
			| NE { $$ = NE; }
			;
addt_exp	: addt_exp addop term
			| term
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
			| factor
			;
mulop		: TIMES | OVER
			;
factor		: LPAREN exp RPAREN
				{ $$ = $2; }
			| var
				{ $$ = $1; }
			| call
				{ $$ = $1; }
			| NUM
			;
call		: ID LPAREN args RPAREN
				{
					// TODO
				}
			;
args		: arg_list
				{ $$ = $1; }
			| /* empty */
			;
arg_list	: arg_list COMMA exp
				{ /* TODO */ }
			| exp
			;
/* user implementation */
assign_stmt : ID { savedName = copyString(tokenString);
                   savedLineNo = lineno; }
              ASSIGN exp
                 { $$ = newStmtNode(AssignK);
                   $$->child[0] = $4;
                   $$->attr.name = savedName;
                   $$->lineno = savedLineNo;
                 }
            ;
exp         : simple_exp LT simple_exp 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = LT;
                 }
            | simple_exp EQ simple_exp
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = EQ;
                 }
            | simple_exp { $$ = $1; }
            ;
simple_exp  : simple_exp PLUS term 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = PLUS;
                 }
            | simple_exp MINUS term
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = MINUS;
                 } 
            | term { $$ = $1; }
            ;
term        : term TIMES factor 
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = TIMES;
                 }
            | term OVER factor
                 { $$ = newExpNode(OpK);
                   $$->child[0] = $1;
                   $$->child[1] = $3;
                   $$->attr.op = OVER;
                 }
            | factor { $$ = $1; }
            ;
factor      : LPAREN exp RPAREN
                 { $$ = $2; }
            | NUM
                 { $$ = newExpNode(ConstK);
                   $$->attr.val = atoi(tokenString);
                 }
            | ID { $$ = newExpNode(IdK);
                   $$->attr.name =
                         copyString(tokenString);
                 }
            | error { $$ = NULL; }
            ;

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

