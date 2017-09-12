#include <mpg123.h>
#include <string.h>
#include <stdio.h>

int main()
{
	int err = 0;
#if MPG123_API_VERSION >= 45
	mpg123_string *sb;
	sb = mpg123_new_string("This is a test!");
	if(strcmp(sb->p, "This is a test!"))
		err++;
	mpg123_delete_string(sb);
#endif
	printf("%s\n", err ? "FAIL" : "PASS");
	return err ? -1 : 0;

}
