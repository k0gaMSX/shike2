
#include <stdio.h>
#include <stdlib.h>

void
die(char *msg)
{
	fputs(msg, stderr);
	putc('\n', stderr);
	exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
	FILE *in = NULL;
	static char addr[5], name[30];

	if (!argv[1])
		in = stdin;
	else
		++argv;

	do {
		if (!in && !(in = fopen(*argv, "r")))
			die("error opening input file");
		while (fscanf(in, " %5s %30s \n", addr, name) > 0 && *name)
			printf("%s\tEQU\t0%sH\n", name, addr);
		if (ferror(in))
			die("error reading input file");
		fclose(in);
	} while (*++argv);

	return 0;
}
