#ifndef __AI_MEM__
#define __AI_MEM__
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void *memcpy(void *dest, const void *src, size_t n)
{
	char *dp = (char *)dest;
	const char *sp = (char *)src;
	while (n--)
		*dp++ = *sp++;
	return dest;
}


void * __attribute__((used)) memset(void *dest, int c, size_t n)
{
	const unsigned char uc = c;
	unsigned char *su;
	for(su = (unsigned char *)dest; 0 < n;++su,--n)
		*su = uc;
	return dest;
}

char * strcpy(char *dest, const char *src)
{
	while ((*dest++ = *src++));
	return dest;
}

char * strncpy(char *dest, const char *src, size_t n)
{
	while (n-- && (*dest++ = *src++));
	return dest;
}

#ifdef __cplusplus
}
#endif

#endif