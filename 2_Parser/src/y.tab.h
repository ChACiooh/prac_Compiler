/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IF = 258,
    ELSE = 259,
    RETURN = 260,
    WHILE = 261,
    INT = 262,
    VOID = 263,
    PLUS = 264,
    MINUS = 265,
    TIMES = 266,
    OVER = 267,
    EQ = 268,
    NE = 269,
    LT = 270,
    LE = 271,
    GT = 272,
    GE = 273,
    ASSIGN = 274,
    LPAREN = 275,
    RPAREN = 276,
    LBRACE = 277,
    RBRACE = 278,
    LCURLY = 279,
    RCURLY = 280,
    SEMI = 281,
    COMMA = 282,
    ID = 283,
    NUM = 284,
    ERROR = 285,
    IFX = 286
  };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define RETURN 260
#define WHILE 261
#define INT 262
#define VOID 263
#define PLUS 264
#define MINUS 265
#define TIMES 266
#define OVER 267
#define EQ 268
#define NE 269
#define LT 270
#define LE 271
#define GT 272
#define GE 273
#define ASSIGN 274
#define LPAREN 275
#define RPAREN 276
#define LBRACE 277
#define RBRACE 278
#define LCURLY 279
#define RCURLY 280
#define SEMI 281
#define COMMA 282
#define ID 283
#define NUM 284
#define ERROR 285
#define IFX 286

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
