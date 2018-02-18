#include <out123.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char **argv)
{
	int err = 0, merr = 0;
	const char *ims = out123_plain_strerror(-100);

	const char* msg = out123_plain_strerror(OUT123_ERR);
	err += merr = (!msg || !strcmp(msg, ims));
	fprintf( stderr, "check OUT123_ERR message: %s (%s)\n"
	,	merr ? "FAIL" : "PASS", msg ? msg : "<nil>" );

	msg = out123_plain_strerror(OUT123_ERRCOUNT);
	err += merr = (!msg || strcmp(msg, ims));
	fprintf( stderr, "check OUT123_ERRCOUNT message: %s (%s)\n"
	,	merr ? "FAIL" : "PASS", msg ? msg : "<nil>" );

	msg = out123_plain_strerror(OUT123_ARG_ERROR);
	err += merr = ( !msg ||
		strncmp(msg, "bad function argument", 21) );
	fprintf( stderr, "check OUT123_ARG_ERROR message: %s (%s)\n"
	,	merr ? "FAIL" : "PASS", msg ? msg : "<nil>" );

	msg = out123_plain_strerror(OUT123_ERRCOUNT-1);
	err += merr = ( !msg || !strcmp(msg, ims) ||
		!strncmp(msg, "outdated error list", 19) );
	fprintf( stderr, "check OUT123_ERRCOUNT-1 message: %s (%s)\n"
	,	merr ? "FAIL" : "PASS", msg ? msg : "<nil>" );

	printf("%s\n", err ? "FAIL" : "PASS");
	return 0;
}
