/*	This file is part of the software similarity tester SIM.
	Written by Dick Grune, VU, Amsterdam; dick@dickgrune.com
	$Id: token.c,v 2.21 2023-05-08 14:07:20 dick Exp $
*/

/*
	Token interface, implementation part.
*/

#include	"token.h"

#include	"global.h"
#include	"any_int.h"

/* Language-specific parameter; may be changed in Init_Language() */
const char *Token_Name = "token";

static int
Token_in_range(const Token tk, int low, int high) {
	int tki = Token_To_Int(tk);
	if (tki < low) return 0;
	if (tki > high) return 0;
	return 1;
}

static int
check_and_print(
	FILE *ofile, const char *name, int ch, int low, int high, int offset
) {
	int ch1 = ch + offset;
	if (low <= ch1 && ch1 <= high) {
		fprintf(ofile, "%s(%c)", name, (char)ch1);
		return 1;
	}
	return 0;
}

#define	is_simple_token(tk)	(Token_in_range(tk, 0x0001, 0x00FF))
#define	is_CTRL_token(tk)	(Token_in_range(tk, 0x0101, 0x011E))
#define	is_NORM_token(tk)	(Token_in_range(tk, 0x0121, 0x017E))
#define	is_MTCT_token(tk)	(Token_in_range(tk, 0x0181, 0x019E))
#define	is_META_token(tk)	(Token_in_range(tk, 0x01A1, 0x01FE))
#define	is_hashed_token(tk)	(Token_in_range(tk, 0x0200, 0xFFFE))

void
fprint_Token(FILE *ofile, const Token tk) {
	/*	Prints a regular token in two characters:
			normal char		meta (bit 9 set)
			^A	cntl		$A	meta-cntl
			 A	printable	#A	meta
		and hashed tokens in hexadecimal.
	*/
	int tki = Token_To_Int(tk);
	int ch =   tki & 0x7F;
	int bit8 = tki & 0x80;


	if (Token_EQ(tk, No_Token))	{fprintf(ofile, "--"); return;}
	if (Token_EQ(tk, IDF))		{fprintf(ofile, "IDF"); return;}
	if (Token_EQ(tk, STR))		{fprintf(ofile, "STR"); return;}
	if (Token_EQ(tk, End_Of_Line))	{fprintf(ofile, "EOL"); return;}

	if (is_simple_token(tk)) {
		if ('!' <= ch && ch <= '~') {
			fprintf(ofile, "%s%c", (bit8 ? "8" : ""), ch);
			return;
		}
		if (0 < ch && ch <= ' ') {
			fprintf(ofile, "%s%c", (bit8 ? "$" : "^"), ch + '@');
			return;
		}
		if (ch == 0x7F) {
			fprintf(ofile, "%s%c", (bit8 ? "$" : "^"), '?');
			return;
		}
	}

	if (is_CTRL_token(tk)) {
		if (check_and_print(ofile, "CTRL", ch, 'A', '~', '@')) return;
	}

	if (is_NORM_token(tk)) {
		if (check_and_print(ofile, "NORM", ch, '!', '~', '\0')) return;
	}

	if (is_MTCT_token(tk)) {
		if (check_and_print(ofile, "MTCT", ch, 'A', '~', '@')) return;
	}

	if (is_META_token(tk)) {
		if (check_and_print(ofile, "META", ch, '!', '~', '\0')) return;
	}

	if (is_hashed_token(tk)) {
		fprintf(ofile, "0x%04x", tki);
		return;
	}

	/* gap token! */
	fprintf(ofile, "!0x%04x!", tki);
}

const char *
size_t2string(size_t s) {
	return any_uint2string(s);
}

/* only active when the macro Token_Eq() has been made inaccessible */
#undef	Token_EQ	/* to make it compile when Token_Eq() is accessible */
#ifdef	lint_test
int
Token_EQ(const Token t1, const Token t2) {
	/* to make sure Token_EQ is indeed called with two Token parameters */
	return Token_To_Int(t1) == Token_To_Int(t2);
}
#endif

