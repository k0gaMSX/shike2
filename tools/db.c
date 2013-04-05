#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define NUMBERDB	8

void
usage(void)
{
	puts("usage: db [-lLABEL] [file]");
	exit(EXIT_FAILURE);
}

void
die(const char *msg)
{
	fprintf(stderr, "db: %s\n", msg);
	exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
	char *label = NULL;
	FILE *input = stdin;

	if (*++argv && argv[0][0] == '-') {
		if (argv[0][1] == 'l')
			label = &argv[0][2];
		else
			usage();
		++argv;
	}

	if (*argv) {
		if ((input = fopen(*argv, "rb")) == NULL)
			die(strerror(errno));
	}

	if (label)
		printf("\tPUBLIC\t%s\n%s:\n", label,label);

	for (;;) {
		int i, c;

		for (i = 0; i < NUMBERDB; ++i) {
			if ((c = getc(input)) == EOF)
				goto end;
			fputs(i == 0 ? "\tDB\t" : ",", stdout);
			printf("%03XH", c);
		}
		putchar('\n');
	}


end:	if (ferror(input))
		die(strerror(errno));

	return 0;
}
