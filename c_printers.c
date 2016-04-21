#include <stdlib.h>
#include <string.h>
#include <stdio.h>


void print_pascal_string(char p_str[256])
{
	char *c_str = (char*)malloc(p_str[0]+1);
	memcpy(c_str, p_str+1, p_str[0]);
	c_str[p_str[0]] = '\0';
	printf(c_str);
	free(c_str);
}
