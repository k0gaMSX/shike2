
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define XYPLANE	0
#define XZPLANE	1
#define YZPLANE	2

unsigned char screen[212][256];
char plane = XYPLANE;

void
die(const char *msg)
{
	puts(msg);
	exit(EXIT_FAILURE);
}

void
usage(void)
{
	die(
"usage: isoconver [-xy] [-xz] [ -yz] file.sc5\n\n"
"-xy\tTransform to xy plane\n"
"-xz\tTransform to xy plane\n"
"-yz\tTransform to yz plane\n"
	);
}

void
genfnames(char *in, char *out)
{
	char *bp;
	size_t len = strlen(in);

	if (len > FILENAME_MAX - 4)
		die("file name too long");

	strcpy(out, in);
	if (!(bp = strrchr(out, '.')))
		bp = in + len;
	strcpy(bp, ".out");
}

void
writesr5(const char *fname, unsigned char *buf)
{
	static FILE *out;
	static size_t offset;
	static unsigned char header[] = {
		0xfe, 0x00, 0x00, 0xff, 0x69, 0x00, 0x00
	};

	if ((out = fopen(fname, "wb")) == NULL)
		die("error opening output file");

	if (fwrite(header, 7, 1, out) != 1)
		die("error writing output header");

	for (offset = 0; offset < 212*128; ++offset) {
		register unsigned char b1, b2;

		b1 = *buf++, b2 = *buf++;
		if (putc(b1 << 4 | b2, out) == EOF)
			die("error writing output file");
	}

	fclose(out);
}


void
readrow(FILE *in, unsigned char *out)
{
	static unsigned char buf[128];
	register unsigned char *bp;

	if (fread(buf, 128, 1, in) != 1)
		die("error reading input file");

	for (bp = buf; bp < buf + 128; ++bp) {
		register unsigned char c = *bp;

		*out++ = c >> 4;
		*out++ = c & 0x0f;
	}
}

void
convert(register unsigned char y, unsigned char *in)
{
	register unsigned x = 0;

	for (x = 0; x < 256; ++in, ++x) {
		static int xr, yr;
		unsigned char *bp;

		switch (plane) {
		case XYPLANE:
			xr = x;
			yr = y >> 1;
			break;
		case XZPLANE:
			xr = x - (y >> 1) + 128;
			yr = y;
			break;		
		case YZPLANE:
			xr = x + (y >> 1) - 64;
			yr = y;
			break;
		}

		if (xr < 0 || yr > 211)
			continue;

		bp = &screen[yr][xr];
		if (!*bp)
			*bp = *in;
	}
}

void
doit(char *fnamein)
{
	FILE *fin;
	static char fnameout[FILENAME_MAX];
	static unsigned char buf[256];
	unsigned char i;

	genfnames(fnamein, fnameout);

	if ((fin = fopen(fnamein, "rb")) == NULL)
		die("error opening input file");
	fseek(fin, 7, SEEK_SET);

	for (i = 0; i < 212; ++i) {
		readrow(fin, buf);
		convert(i, buf);
	}
	writesr5(fnameout, &screen[0][0]);
}

int
main(int argc, char *argv[])
{
	char *file, *opt;

	while (opt = *++argv) {
		if (*opt != '-')
			break;
		++opt;
		if (!strcmp(opt, "xy"))
			plane = XYPLANE;
		else if (!strcmp(opt, "xz"))
			plane = XZPLANE;
		else if (!strcmp(opt, "yz"))
			plane = YZPLANE;
		else
			usage();
	}

	if (!(file = opt))
		usage();

	doit(file);
	return 0;
}
