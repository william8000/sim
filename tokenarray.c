/*	This file is part of the software similarity tester SIM.
	Written by Dick Grune, VU, Amsterdam; dick@dickgrune.com
	$Id: tokenarray.c,v 1.30 2020-08-14 16:56:54 dick Exp $
*/

#include	"tokenarray.h"

#include	"global.h"
#include	"Malloc.h"
#include	"token.h"

#define	Initial_Token_Array_Size	(16384)

Token *Token_Array;			/* to be filled by Malloc() */
static size_t tk_size;			/* size of Token_Array[] */
static size_t tk_free;			/* next free position in Token_Array[]*/

void
Init_Token_Array(void) {
	if (Token_Array) Free(Token_Array);
	tk_size = Initial_Token_Array_Size;
	Token_Array = (Token *)Malloc(sizeof (Token) * tk_size);
	tk_free = 1;		/* don't use position 0 */
}

void
Store_In_Token(Token tk) {
	if (tk_free == tk_size) {
		/* allocated array is full; try to increase its size */
		Token *new_array;
		size_t new_size = tk_size + tk_size/2;
		if (new_size < tk_free)
			Fatal("out of address space");

		new_array =
			(Token *)Try_Realloc(
				(char *)Token_Array, sizeof (Token) * new_size
			);

		if (!new_array) {
			/* we failed */
			Fatal("out of memory: too much text");
		}
		Token_Array = new_array, tk_size = new_size;
	}

	/* now we are sure there is room enough */
	Token_Array[tk_free++] = tk;
}

void
Free_Token_Array(void) {
	if (Token_Array) {
		Free(Token_Array); Token_Array = 0;
	}
}

size_t
Token_Array_Length(void) {
	return tk_free;
}
