%{
/*	This file is part of the software similarity tester SIM.
	Written by Dick Grune, VU, Amsterdam; dick@dickgrune.com
	$Id: clang.l,v 2.31 2020-08-14 16:56:50 dick Exp $
*/

/*
	php language front end for the similarity tester.
	based on the c language front end by
	Author:	Dick Grune <dick@cs.vu.nl>
	Date:	1986-05-18
	Modified for php by WB: 2025-03-14
*/

#include	"global.h"
#include	"options.h"
#include	"token.h"
#include	"properties.h"
#include	"idf.h"
#include	"lex.h"
#include	"lang.h"

/* General language front end data */
Token lex_token;
size_t lex_nl_cnt;
size_t lex_tk_cnt;
size_t lex_non_ASCII_cnt;

/* Language-dependent data */

/* Data for module idf */

static const struct idf reserved[] = {
	{"abstract",	NORM('a')},
	{"and",		NORM('A')},
	{"array",	CTRL('a')},
	{"as",		CTRL('A')},
	{"break",	NORM('b')},
	{"callable",	NORM('c')},
	{"case",	NORM('C')},
	{"catch",	CTRL('c')},
	{"class",	CTRL('C')},
	{"clone",	META('c')},
	{"const",	META('C')},
	{"continue",	MTCT('c')},
	{"declare",	NORM('d')},
	{"default",	NORM('D')},
	{"die",		CTRL('d')},
	{"do",		CTRL('D')},
	{"echo",	NORM('e')},
	{"else",	NORM('E')},
	{"elseif",	CTRL('e')},
	{"empty",	CTRL('E')},
	{"enddeclare",	META('e')},
	{"endfor",	META('E')},
	{"endforeach",	MTCT('e')},
	{"endif",	MTCT('E')},
	{"endswitch",	META('d')},
	{"endwhile",	META('D')},
	{"eval",	MTCT('d')},
	{"exit",	MTCT('D')},
	{"extends",	NORM('e')},
	{"final",	NORM('f')},
	{"finally",	NORM('F')},
	{"fn",		CTRL('f')},
	{"for",		CTRL('F')},
	{"foreach",	META('f')},
	{"function",	META('F')},
	{"global",	NORM('g')},
	{"goto",	NORM('G')},
	{"if",		NORM('i')},
	{"implements",	NORM('I')},
	{"include",	CTRL('i')},
	{"include_once",CTRL('I')},
	{"instanceof",	META('i')},
	{"insteadof",	META('I')},
	{"interface",	MTCT('i')},
	{"isset",	MTCT('I')},
	{"list",	NORM('l')},
	{"match",	NORM('m')},
	{"namespace",	NORM('n')},
	{"new",		NORM('N')},
	{"or",		NORM('o')},
	{"print",	NORM('p')},
	{"private",	NORM('P')},
	{"protected",	CTRL('p')},
	{"public",	CTRL('P')},
	{"readonly",	NORM('r')},
	{"require",	NORM('R')},
	{"require_once",CTRL('r')},
	{"return",	CTRL('R')},
	{"static",	NORM('s')},
	{"switch",	NORM('S')},
	{"throw",	NORM('t')},
	{"trait",	NORM('T')},
	{"try",		CTRL('t')},
	{"unset",	NORM('u')},
	{"use",		NORM('U')},
	{"var",		NORM('v')},
	{"while",	NORM('w')},
	{"xor",		NORM('x')},
	{"yield",	NORM('y')},
	{"yield_from",	NORM('Y')}
};

/* Special treatment of identifiers */

static Token
idf2token(int hashing) {
	Token tk;

	tk = Idf_In_List(yytext, reserved, sizeof reserved, IDF);
	if (Token_EQ(tk, IDF) && hashing) {
		/* return a one-Token hash code */
		tk = Idf_Hashed(yytext);
	}
	return tk;
}

/* Token sets for properties module */
static const Token Non_Finals[] = {
	IDF,		/* identifier */
	NORM('{'),
	NORM('('),
	NORM('a'),	/* abstract */
	NORM('A'),	/* and */
	CTRL('a'),	/* array */
	CTRL('A'),	/* as */
	NORM('b'),	/* break */
	NORM('c'),	/* callable */
	NORM('C'),	/* case */
	CTRL('c'),	/* catch */
	CTRL('C'),	/* class */
	META('c'),	/* clone */
	META('C'),	/* const */
	MTCT('c'),	/* continue */
	NORM('d'),	/* declare */
	NORM('D'),	/* default */
	CTRL('d'),	/* die */
	CTRL('D'),	/* do */
	NORM('e'),	/* echo */
	NORM('E'),	/* else */
	CTRL('e'),	/* elseif */
	CTRL('E'),	/* empty */
	META('e'),	/* enddeclare */
	META('E'),	/* endfor */
	MTCT('e'),	/* endforeach */
	MTCT('E'),	/* endif */
	META('d'),	/* endswitch */
	META('D'),	/* endwhile */
	MTCT('d'),	/* eval */
	MTCT('D'),	/* exit */
	NORM('e'),	/* extends */
	NORM('f'),	/* final */
	NORM('F'),	/* finally */
	CTRL('f'),	/* fn */
	CTRL('F'),	/* for */
	META('f'),	/* foreach */
	META('F'),	/* function */
	NORM('g'),	/* global */
	NORM('G'),	/* goto */
	NORM('i'),	/* if */
	NORM('I'),	/* implements */
	CTRL('i'),	/* include */
	CTRL('I'),	/* include_once */
	META('i'),	/* instanceof */
	META('I'),	/* insteadof */
	MTCT('i'),	/* interface */
	MTCT('I'),	/* isset */
	NORM('l'),	/* list */
	NORM('m'),	/* match */
	NORM('n'),	/* namespace */
	NORM('N'),	/* new */
	NORM('o'),	/* or */
	NORM('p'),	/* print */
	NORM('P'),	/* private */
	CTRL('p'),	/* protected */
	CTRL('P'),	/* public */
	NORM('r'),	/* readonly */
	NORM('R'),	/* require */
	CTRL('r'),	/* require_once */
	CTRL('R'),	/* return */
	NORM('s'),	/* static */
	NORM('S'),	/* switch */
	NORM('t'),	/* throw */
	NORM('T'),	/* trait */
	CTRL('t'),	/* try */
	NORM('u'),	/* unset */
	NORM('U'),	/* use */
	NORM('v'),	/* var */
	NORM('w'),	/* while */
	NORM('x'),	/* xor */
	NORM('y'),	/* yield */
	NORM('Y'),	/* yield_from */
	No_Token
};

static const Token Non_Initials[] = {
	NORM(')'),
	NORM('}'),
	NORM(';'),
	No_Token
};

static const Token Openers[] = {
	NORM('{'),
	NORM('('),
	NORM('['),
	No_Token
};

static const Token Closers[] = {
	NORM('}'),
	NORM(')'),
	NORM(']'),
	No_Token
};

/* Language-dependent code */

void
Init_Language(void) {
	Subject = "php programs";
	Init_Language_Properties(Non_Finals, Non_Initials, Openers, Closers);
}

/* UTF-8 bytes in strings and comment are absorbed in patterns starting
   with [^...]. Non-ASCII chars outside strings or comments are counted in
   lex_non_ASCII_cnt.
*/

%}

%option	noyywrap

%Start	Comment

Layout		([ \t\r\f])
ASCII95		([\040-\176])

AnyQuoted	(\\.)
StrChar		([^\"\n\\]|{AnyQuoted})
ChrChar		([^\'\n\\]|{AnyQuoted})

StartComment	("/*")
EndComment	("*/")
SafeComChar	([^*\n])
UnsafeComChar	("*")

MSComment	("//"{MSCommentChar}*)
MSCommentChar	([^\n])

HexDigit	([0-9a-fA-F])
Idf		([A-Za-z_][A-Za-z0-9_]*)

%%

{StartComment}	{
		/*	We do not have one single pattern to match a comment
			(although one can be written), for two reasons.
			The matched string might overflow lex-internal buffers
			like yysbuf and yytext; and the pattern would be very
			complicated and impair maintainability.
			So we break up the string into safe chunks and keep
			track of where we are in a start condition <Comment>.
		*/
		BEGIN Comment;
	}

<Comment>{SafeComChar}+	{		/* safe comment chunk */
	}

<Comment>{UnsafeComChar}	{	/* unsafe char, read one by one */
	}

<Comment>"\n"		{		/* to break up long comments */
		return_eol();
	}

<Comment>{EndComment}	{		/* end-of-comment */
		BEGIN INITIAL;
	}

{MSComment}	{			/* ignore */
	}

\"{StrChar}*\"	{			/* strings */
		return_ch(STR);
	}

\'{ChrChar}+\'	{			/* characters */
		return_ch('\'');
	}

(0x)?{HexDigit}+("l"|"L")?	{	/* numeral, passed as an identifier */
		return_tk(IDF);
	}

{Idf}/"("	{			/* identifier in front of ( */
		Token tk;

		tk = idf2token(Is_Set_Option('F'));
		if (!Token_EQ(tk, No_Token)) return_tk(tk);
	}

{Idf}	{				/* identifier */
		Token tk;

		tk = idf2token(0 /* no hashing */);
		if (!Token_EQ(tk, No_Token)) return_tk(tk);
	}

\;	{				/* semicolon, conditionally ignored */
		if (Is_Set_Option('f')) return_ch(yytext[0]);
	}

\n	{				/* count newlines */
		return_eol();
	}

{Layout}	{			/* ignore layout */
	}

{ASCII95}	{			/* copy other text */
		return_ch(yytext[0]);
	}

.	{				/* count non-ASCII chars */
		lex_non_ASCII_cnt++;
	}

%%

/* More language-dependent code */

void
yystart(void) {
	BEGIN INITIAL;
}
