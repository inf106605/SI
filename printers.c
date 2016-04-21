#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>


void print_pascal_string(uint8_t p_str[256])
{
	char *c_str = (char*)malloc(p_str[0]+1);
	memcpy(c_str, p_str+1, p_str[0]);
	c_str[p_str[0]] = '\0';
	printf(c_str);
	free(c_str);
}

void print_int8(int8_t i)
{
	printf("%i\n", (int)i);
}

void print_uint8(uint8_t i)
{
	printf("%u\n", (int)i);
}

void print_int16(int16_t i)
{
	printf("%i\n", (int)i);
}

void print_uint16(uint16_t i)
{
	printf("%u\n", (int)i);
}

void print_int32(int32_t i)
{
	printf("%i\n", (int)i);
}

void print_uint32(uint32_t i)
{
	printf("%u\n", (int)i);
}
