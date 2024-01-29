#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BMP_TYPE            0    /* Type of BMP */
#define BMP_FILE_SIZE       2    /* Size of the file, including header */
#define BMP_RESERVED        6    /* Reserved bytes */
#define BMP_BITMAP_OFFSET  10    /* Offset of the bitmap in the file */
#define BMP_HEAD_SIZE      14    /* Size of the header, 40 for Win BMP */
#define BMP_XSIZE          18    /* X size */
#define BMP_YSIZE          22    /* Y size */
#define BMP_PLANES         26    /* Number of planes */
#define BMP_BITS           28    /* Number of bits per pixel */
#define BMP_COMPRESSION    30    /* Type of compression */
#define BMP_IMG_SIZE       34    /* Size of the image if it is compressed */
#define BMP_XRESOL         38    /* X Resolution */
#define BMP_YRESOL         42    /* Y Resolution */
#define BMP_NCOLOR         46    /* Number of colors */
#define BMP_NCOLOR_IMP     50    /* Number of important colors */

#define BMP_HEAD           14    /* Size of BMP header */
#define PIB_HEAD           40    /* Size of PIB header */
#define BMP_HEAD_FILE      (BMP_HEAD + PIB_HEAD)

#define BMP_PAL_SIZE       (16*4) /* Size of the pallete */

#define RESOLUTION         2835  /* 72 pixels per centimeter */

struct image {
	char *pal;
	char *data;
};

static long
unpack4(unsigned char *p, int offset)
{
	unsigned long l;

	l = p[offset];
	l |= p[offset + 1] << 8;
	l |= p[offset + 2] << 16;
	l |= p[offset + 3] << 24;

	return l;	
}

static int
unpack2(unsigned char *p, int offset)
{
	unsigned s;

	s = p[offset];
	s |= p[offset + 1] << 8;

	return s;	
}

static void
readbmp(char *name, struct image *img)
{
	FILE *fp;
	int i, h, w, ncol;
	unsigned char pal[4 * 16], *p, *q;
	unsigned char header[BMP_HEAD_FILE];

	if ((fp = fopen(name, "rb")) == NULL)
		goto syserr;

	if (fread(header, BMP_HEAD_FILE, 1, fp) != 1)
		goto syserr;

	if (header[BMP_TYPE] != 'B' && header[BMP_TYPE+1] != 'M'
	|| header[BMP_COMPRESSION] != 0
	|| header[BMP_BITS] != 4
	|| header[BMP_PLANES] != 1) {
		goto invalid_format;
	}

	h = unpack2(header, BMP_YSIZE);
	w = unpack2(header, BMP_XSIZE);
	ncol = unpack2(header, BMP_NCOLOR);
	if (ncol == 0)
		ncol = 16;
	
	if (w != 256 && h != 212)
		goto invalid_format;

	img->data = calloc(212, 128);
	img->pal = malloc(2 * 16);
	if (!img->data || !img->pal)
		goto syserr;

	memset(pal, 0, sizeof(pal));
	fseek(fp, BMP_HEAD + unpack4(header, BMP_HEAD_SIZE), SEEK_SET);
	fread(pal, 4, ncol, fp);

	fseek(fp, unpack4(header, BMP_BITMAP_OFFSET), SEEK_SET);
	p = &img->data[128 * 211];
	for (i = 0; i < 212; i++) {
		fread(p, 128, 1, fp);
		p -= 128;
	}

	p = pal;
	q = img->pal;
	for (i = 0; i < 16; i++) {
		int r, g, b, a;

		r = *p++;
		g = *p++;
		b = *p++;
		a = *p++;

		*q++ = r << 4 | b;
		*q++ = g;		
	}

	if (ferror(fp))
		goto syserr;

	fclose(fp);
	return;

syserr:
	perror("bmp2sr5: reading input file");
	exit(EXIT_FAILURE);

invalid_format:
	fputs("bmp2sr5: BMP format not supported\n", stderr);
	exit(EXIT_FAILURE);
}

static void
writesr5(char *fname, struct image *img)
{
	int i;
	FILE *fp;
	static char hdr[] = {
		'\xfe', '\x00', '\x00', '\x00', '\x6a', '\x00', '\x00'
	};

	if ((fp = fopen(fname, "wb")) == NULL)
		goto syserr;

	fwrite(hdr, sizeof(hdr), 1, fp);
	fwrite(img->data, 212, 128, fp);

	if (ferror(fp))
		goto syserr;
	fclose(fp);

	return;

syserr:
	perror("bmp2sr5: writing output sr5 file");
	remove(fname);
	exit(EXIT_FAILURE);
}

static void
usage(void)
{
	fputs("bmp2sr5 [-o output] file\n", stderr);
	exit(EXIT_FAILURE);
}

static char *
getarg(char **args, char ***argv)
{
	char *s;

	if ((*args)[1]) {
		s = (*args) + 1;
		*args += strlen(*args) - 1;
		return s;
	}

	if (!argv)
		usage();

	if ((*argv)[1] == NULL)
		usage();
	(*argv)++;

	return **argv;
}

int
main(int argc, char *argv[])
{
	int w, h;
	char *sc5, *bmp, *dot, *p;
	struct image img;

	sc5 = NULL;
	for (--argc; *++argv; --argc) {
		if (argv[0][0] != '-')
			break;
		for (p = *argv+1; *p; ++p) {
			switch (*p) {
			case 'o':
				sc5 = getarg(&p, &argv);
				break;
			default:
				usage();
			}
		}
	}

	if (argc != 1)
		usage();

	bmp = *argv;

	if (!sc5) {
		dot = strrchr(bmp, '.');
		if (!dot || strcmp(dot+1, "bmp")) {
			fputs("bmp2sr5: unknown output file name\n", stderr);
			exit(EXIT_FAILURE);
		}
		sc5 = malloc(strlen(bmp)+1);
		sprintf(sc5, "%.*s.sr5", dot - bmp, bmp);
	}

	readbmp(bmp, &img);
	writesr5(sc5, &img);

	return 0;
}
