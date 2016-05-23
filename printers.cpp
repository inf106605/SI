#include <cstring>
#include <cstdio>
#include <cstdint>


extern "C"
void print_pascal_string(uint8_t p_str[256])
{
	char *c_str = new char[p_str[0]+1];
	std::memcpy(c_str, p_str+1, p_str[0]);
	c_str[p_str[0]] = '\0';
	std::printf(c_str);
	delete[] c_str;
	std::fflush(stdout);
}

extern "C"
void println_pascal_string(uint8_t p_str[256])
{
	char *c_str = new char[p_str[0]+1];
	std::memcpy(c_str, p_str+1, p_str[0]);
	c_str[p_str[0]] = '\0';
	std::printf("%s\n", c_str);
	delete[] c_str;
	std::fflush(stdout);
}

extern "C"
void print_int8(int8_t i)
{
	std::printf("%i", (int)i);
	std::fflush(stdout);
}

extern "C"
void println_int8(int8_t i)
{
	std::printf("%i\n", (int)i);
	std::fflush(stdout);
}

extern "C"
void print_uint8(uint8_t i)
{
	std::printf("%u", (int)i);
	std::fflush(stdout);
}

extern "C"
void println_uint8(uint8_t i)
{
	std::printf("%u\n", (int)i);
	std::fflush(stdout);
}

extern "C"
void print_int16(int16_t i)
{
	std::printf("%i", (int)i);
}

extern "C"
void println_int16(int16_t i)
{
	std::printf("%i\n", (int)i);
}

extern "C"
void print_uint16(uint16_t i)
{
	std::printf("%u", (int)i);
	std::fflush(stdout);
}

extern "C"
void println_uint16(uint16_t i)
{
	std::printf("%u\n", (int)i);
	std::fflush(stdout);
}

extern "C"
void print_int32(int32_t i)
{
	std::printf("%i", (int)i);
	std::fflush(stdout);
}

extern "C"
void println_int32(int32_t i)
{
	std::printf("%i\n", (int)i);
	std::fflush(stdout);
}

extern "C"
void print_uint32(uint32_t i)
{
	std::printf("%u", (int)i);
	std::fflush(stdout);
}

extern "C"
void println_uint32(uint32_t i)
{
	std::printf("%u\n", (int)i);
	std::fflush(stdout);
}
