/*	This file is part of the software similarity tester SIM.
	Written by Dick Grune, VU, Amsterdam; dick@dickgrune.com
	$Id: properties.c,v 2.5 2020-08-14 16:56:52 dick Exp $
*/

#include	"properties.h"

#include	"global.h"
#include	"options.h"
#include	"token.h"

/*	Arrays for fast identification tests for tokens.  Each token is
	identified by its position in the set + 1.  For example, if tk is
	the n-th Opener, openers[Token_To_Int(tk)] == n+1.
*/
static char non_finals[N_REGULAR_TOKENS];
static char non_initials[N_REGULAR_TOKENS];
static char openers[N_REGULAR_TOKENS];
static char closers[N_REGULAR_TOKENS];

						/* Init_Language */
static void
cvt2bittable(const Token *tl, char bt[]) {
	if (!tl) return;

	/* assumes bt[] is cleared */
	int i;
	int cnt = 1;

	for (i = 0; !Token_EQ(tl[i], No_Token); i++) {
		int index = Token_To_Int(tl[i]);
		if (index < 0 || index >= N_REGULAR_TOKENS)
			Fatal("internal error: bad Token list");
		bt[index] = (char)(cnt++);
	}
}

void
Init_Language_Properties(
	const Token Non_Finals[],
	const Token Non_Initials[],
	const Token Openers[],
	const Token Closers[]
) {
	/* convert the token sets to bitmaps for speed-up */
	cvt2bittable(Non_Initials, non_initials);
	cvt2bittable(Non_Finals, non_finals);
	cvt2bittable(Openers, openers);
	cvt2bittable(Closers, closers);
}

						/* May_Be_Start_Of_Run */
static int
is_in_set(const char set[], const Token tk) {
	if (!Is_Regular_Token(tk)) return 0;
	return set[Token_To_Int(tk)];
}

int
May_Be_Start_Of_Run(const Token tk) {
	return !is_in_set(non_initials, tk);
}

						/* Best_Run_Size */
static size_t
largest_routine(const Token *tk_array, size_t size) {
	/*	Returns the size of the longest sequence starting at
		tk_array[0] and not containing unbalanced parentheses.
		Does not check the nesting of the parentheses, but then,
		sim is syntax-free anyway.
	*/
	size_t mrb_size = 0;  	/* most recent balancing size */
	size_t pos;
	int i;
	int balance_count[N_REGULAR_TOKENS];
	/* Overkill: only a fraction of the tokens are balancers; oh well. */
	int n_imbalances;

	/* clear administration */
	n_imbalances = 0;
	for (i = 0; i < N_REGULAR_TOKENS; i++) {
		balance_count[i] = 0;
	}

	/* scan tk_array[] and see how far we get */
	for (pos = 0; pos < size; pos++) {
		Token tk = tk_array[pos];
		int pp;		/* parenthesis position */

		/* account for openers */
		if ((pp = is_in_set(openers, tk))) {
			if (balance_count[pp] == 0) {
				/* about to create an imbalance */
				n_imbalances++;
			}
			balance_count[pp]++;
		}

		/* account for closers */
		if ((pp = is_in_set(closers, tk))) {
			if (balance_count[pp] == 0) {
				/* this is one Closer too many */
				return mrb_size;
			}
			balance_count[pp]--;
			if (balance_count[pp] == 0) {
				/* we just cleared an imbalance */
				n_imbalances--;
			}
		}

		if (n_imbalances == 0) {
			/* register the balance point */
			mrb_size = pos + 1;
		}
	}
	return mrb_size;
}

size_t
Best_Run_Size(const Token *tk_array, size_t size) {
	/*	Checks the run starting at tk_array[0] with length size for
		acceptability in the language.  Cuts from the end if necessary
		and returns the accepted length, which may be zero.
	*/

	if (Is_Set_Option('f')) {
		/* reduce to a routine-like form first */
		size = largest_routine(tk_array, size);
	}

	while (	/* there is trailing garbage */
	       size != 0 && is_in_set(non_finals, tk_array[size-1])
	) {
		/* remove it */
		size--;
	}

	return size;
}
