
#include <stdio.h>
#include <stdlib.h>

void
die(char *msg)
{
	fputs(msg, stderr);
	putc('\n', stderr);
	exit(EXIT_FAILURE);
}

void
usage(void)
{
	puts("usage: fon2spr [-lLABEL] [input.obj]");	
	exit(EXIT_SUCCESS);
}

int
main(char argc, char *argv[])
{
	FILE *in;
	unsigned i,j;
	char *label = NULL;
	static unsigned char buf[8][128];

        if (*++argv && argv[0][0] == '-') {
                if (argv[0][1] == 'l')
                        label = &argv[0][2];
                else
                        usage();
                ++argv;
        }

	if (!*argv)
		usage();
	
	if ((in = fopen(*argv, "rb")) == NULL)
		die("Error opening input file");

	if (fread(buf, 1024, 1, in) != 1)
		die("Error reading fonts");

	if (label)
		printf("%s:\n", label);

	for (i = 0; i < 64; i++) {
		unsigned char *bp = &buf[0][i*2];

		fputs("\tDB\t", stdout);
		for (j = 0; j < 8; j++, bp += 128) {
			unsigned char c1 = bp[0], c2 = bp[1];
			unsigned c;

			c = ((c1 & 0xf0) != 0) << 3 |
			    ((c1 & 0xf) != 0) << 2  |
			    ((c2 & 0xf0) != 0) << 1 |
			    c2 & 0xf; 
			printf("0%02XH%c", c, j == 7 ? '\n' : ',');
		}
	}

	return 0;
}
