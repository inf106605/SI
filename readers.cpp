#include <cstring>
#include <cstdio>
#include <cstdint>


extern "C"
void read_pascal_string(uint8_t p_str[256])
{
	char c_str[256];
	std::scanf("%s", c_str);
	const uint8_t length = std::strlen(c_str);
	p_str[0] = length;
	std::memcpy(p_str+1, c_str, length);
}

extern "C"
int8_t read_int8()
{
	int result;
	std::scanf("%i", &result);
	return result;
}

extern "C"
uint8_t read_uint8()
{
	int result;
	std::scanf("%i", &result);
	return result;
}

extern "C"
int16_t read_int16()
{
	int result;
	std::scanf("%i", &result);
	return result;
}

extern "C"
uint16_t read_uint16()
{
	int result;
	std::scanf("%i", &result);
	return result;
}

extern "C"
int32_t read_int32()
{
	int result;
	std::scanf("%i", &result);
	return result;
}

extern "C"
uint32_t read_uint32()
{
	int result;
	std::scanf("%i", &result);
	return result;
}
