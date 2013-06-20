
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void
usage(void)
{
	puts("usage: gl52pag [input.gl5] [output.dat]");
	exit(EXIT_FAILURE);
}

void
die(char *msg)
{
	fprintf(stderr, "gl52pag: %s\n", msg);
	exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
	FILE *in = stdin, *out = stdout;
	int c;

	if (argc > 3)
		usage();

	if (*++argv) {
		if ((in = fopen(*argv, "rb")) == NULL)
			die(strerror(errno));
	}
	if (*argv && *++argv) {
		if ((out = fopen(*argv, "wb")) == NULL)
			die(strerror(errno));
	}
	getc(in), getc(in), getc(in), getc(in);

	while ((c = getc(in)) != EOF)
		putc(c, out);

	if (ferror(in))
		die(strerror(errno));
}

