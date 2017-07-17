/* Assume native byte order input, always big endian hex output. */

#include <unistd.h>
#include <stdio.h>
#include <stdint.h>

#define BIG_ENDIAN 1
#define LIL_ENDIAN 2

int endian(void)
{
  unsigned long i,a=0,b=0,c=0;

  for(i=0;i<sizeof(unsigned long);i++) {
    ((unsigned char *)&a)[i] = i;
    b<<=8;
    b |= i;
    c |= i << (i*8);
  }
  if     (a == b) return BIG_ENDIAN;
  else if(a == c) return LIL_ENDIAN;
  else            return 0;
}


int main()
{
	const size_t bufs = 3*1024;
	size_t got;
	unsigned char f[bufs];
	int end = endian();
	while( (got = fread(f, 3, 1024, stdin)) )
	{
		size_t fi;
		for(fi=0; fi<got; ++fi)
		{
			unsigned char *v = &f[fi*3];
			switch(end)
			{
				case BIG_ENDIAN:
					printf("%02x%02x%02x\n", v[0], v[1], v[2]);
				break;
				case LIL_ENDIAN:
					printf("%02x%02x%02x\n", v[2], v[1], v[0]);
				break;
			}
		}
	}
	return 0;
}
