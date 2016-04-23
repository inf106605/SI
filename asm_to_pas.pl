%load input and save output
main() :-
	read_stream_to_codes(user_input, Asm),
	program(Pas, Asm, []),
	writef("%s", [Pas]),
	halt.

%-------------------------------------------------------------------------------

program(Program) -->
	program_header(Header),
	non_significant_lines(),
	constants(Constants),
	non_significant_lines(),
	main_function(Main),
	end_non_significant_lines(),
	{ append([Header, Constants, Main], Program) }.

program_header(Header) --> program_header_lines(), last_program_header_line(), { Header = "PROGRAM Prog;\n" }.
program_header_lines() --> program_header_line(), program_header_lines().
program_header_lines() --> "".
program_header_line() --> non_significant_line() | program_header_global_line() | program_header_extern_line().
program_header_global_line() --> maybe_whitespaces(), "global", whitespaces(), name(_), non_significant_thing(), "\n".
program_header_extern_line() --> maybe_whitespaces(), "extern", whitespaces(), name(_), non_significant_thing(), "\n".
last_program_header_line() --> maybe_whitespaces(), "section", whitespaces(),".text", non_significant_thing(), "\n".

constants(Constants) --> constant_lines(ConstantLines), { append("\nCONST\n", ConstantLines, Constants) }.
constants(Constants) --> "", { Constants = "" }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), non_significant_lines(), constant_lines(RestOfConstantLines), { append(ConstantLine, RestOfConstantLines, ConstantLines) }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), { ConstantLines = ConstantLine }.
constant_line(ConstantLine) --> label(Name), non_significant_lines(), maybe_whitespaces(), "db", constant_data(Data), non_significant_thing(), "\n", { append(["\t", Name, " = ", Data, ";\n"], ConstantLine) }.
constant_data(Data) --> constant_string(Data).
%TODO more types

constant_string(ConstantString) --> whitespaces(), number(_), constant_string_part(StringPart), { ConstantString = StringPart }.
constant_string_part(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), number(Number), constant_string_part(NextStringPart), { append(["#", Number, NextStringPart], StringPart) }.
constant_string_part(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), string(String), constant_string_part(NextStringPart), { append(["'", String, "'", NextStringPart], StringPart) }.
constant_string_part(StringPart) --> "", { StringPart = "" }.

main_function(Main) --> main_function_header(), function_body(Body), { append(["\nBEGIN\n", Body, "END.\n"], Main) }.
main_function_header() --> function_header("main").

function_header(Name) --> label([95|Name]).

label(Name) --> maybe_whitespaces(), name(Name), ":", non_significant_thing(), "\n".

function_body(Body) --> function_line(Line), "\n", function_body(BodyPart), { append(Line, BodyPart, Body) }.
function_body(Body) --> return_instruction(Return), "\n", { Body = Return }.

return_instruction(Return) --> maybe_whitespaces(), "ret", non_significant_thing(), { Return = "\n" }.
	
function_line(Line) --> non_significant_thing(), { Line = "" }.
%TODO real instructions

end_non_significant_lines() --> non_significant_line(), end_non_significant_lines().
end_non_significant_lines() --> non_significant_thing().
non_significant_lines() --> non_significant_line(), non_significant_lines().
non_significant_lines() --> "".
non_significant_line() --> non_significant_thing(), "\n".

non_significant_thing() --> maybe_whitespaces(), maybe_comment().

maybe_comment() --> "" | comment().
comment() --> ";", maybe_no_newline_characters().

maybe_whitespaces() --> "" | whitespaces().
whitespaces() --> whitespace(), whitespaces().
whitespaces() --> whitespace().
whitespace() --> " " | "\t".

name(Name) --> non_digit_name_character(Char), rest_of_name(RestOfName), { append(Char, RestOfName, Name) }. %not sure if it is good - check assembler documentation
rest_of_name(Name) --> name_character(Char), rest_of_name(RestOfName), { append(Char, RestOfName, Name) }.
rest_of_name(Name) --> "", { Name = "" }.

name_character(Char) --> digit(Char) | non_digit_name_character(Char).
non_digit_name_character(Char) --> letter(Char) | other_name_character(Char).
other_name_character(Char) --> "_", { Char = "_" }.
other_name_character(Char) --> ".", { Char = "." }.

string(String) --> "'", string_part(StringPart), "'", { String = StringPart }.
string_part(StringPart) --> string_char(Char), string_part(NextStringPart), { append(Char, NextStringPart, StringPart) }.
string_part(StringPart) --> "", { StringPart = "" }.
string_char(Char) --> [C], { C \= 10, C \= 39, Char = [C] }.

letter(Letter) --> [LetterCode], { code_type(LetterCode, alpha), Letter = [LetterCode] }.

number(Number) --> digit(Digit), number(NumberPart), { append(Digit, NumberPart, Number) }.
number(Number) --> "", { Number = "" }.
digit(Digit) --> [DigitCode], { code_type(DigitCode, digit), Digit = [DigitCode] }.

maybe_no_newline_characters() --> "" | no_newline_characters().
no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { not(head_is_the_same([C], "\n")) }.

head_is_the_same([H1|_], [H2|_]) :- H1 == H2.
