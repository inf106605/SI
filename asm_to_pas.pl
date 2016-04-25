%------------------------------------ MAIN -------------------------------------

main() :-
	read_stream_to_codes(user_input, Asm),
	program(Pas, Asm, []),
	writef("%s", [Pas]),
	halt.


%-------------------------------------------------------------------------------
%--------------------------------- DCG  PARSER ---------------------------------
%-------------------------------------------------------------------------------


%----------------------------------- PROGRAM -----------------------------------

program(Program) -->
	program_header(Header),
	non_significant_lines(),
	constants(Constants),
	non_significant_lines(),
	main_function(Main),
	end_non_significant_lines(),
	{ append([Header, Constants, Main], Program) }.

%----------------------------------- HEADER ------------------------------------

program_header(Header) --> program_header_lines(), last_program_header_line(), { Header = "PROGRAM Prog;\n" }.
program_header_lines() --> program_header_line(), program_header_lines().
program_header_lines() --> "".
program_header_line() --> non_significant_line() | program_header_global_line() | program_header_extern_line().
program_header_global_line() --> maybe_whitespaces(), "global", whitespaces(), name(_), non_significant_thing(), "\n".
program_header_extern_line() --> maybe_whitespaces(), "extern", whitespaces(), name(_), non_significant_thing(), "\n".
last_program_header_line() --> maybe_whitespaces(), "section", whitespaces(),".text", non_significant_thing(), "\n".

%---------------------------------- CONSTANTS ----------------------------------

constants(Constants) --> constant_lines(ConstantLines), { append("\nCONST\n", ConstantLines, Constants) }.
constants(Constants) --> "", { Constants = "" }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), non_significant_lines(), constant_lines(RestOfConstantLines), { append(ConstantLine, RestOfConstantLines, ConstantLines) }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), { ConstantLines = ConstantLine }.
constant_line(ConstantLine) --> label(Name), non_significant_lines(), maybe_whitespaces(), "db", constant_data(Data), non_significant_thing(), "\n", { append(["\t", Name, " = ", Data, ";\n"], ConstantLine) }.
constant_data(Data) --> constant_string(Data).
%TODO more types

%------------------------------- string constant -------------------------------

constant_string(ConstantString) --> whitespaces(), number(_), constant_string_part(StringPart), { ConstantString = StringPart }.
constant_string_part(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), number(Number), constant_string_part(NextStringPart), { append(["#", Number, NextStringPart], StringPart) }.
constant_string_part(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), string(String), constant_string_part(NextStringPart), { append(["'", String, "'", NextStringPart], StringPart) }.
constant_string_part(StringPart) --> "", { StringPart = "" }.

string(String) --> "'", string_part(StringPart), "'", { String = StringPart }.
string_part(StringPart) --> string_char(Char), string_part(NextStringPart), { append(Char, NextStringPart, StringPart) }.
string_part(StringPart) --> "", { StringPart = "" }.
string_char(Char) --> [C], { C \= '\n', C \= '\'', Char = [C] }.

%---------------------------------- FUNCTIONS ----------------------------------

function_header(Name) --> function_label([95|Name]).

function_label(Name) --> label(Name).

%-------------------------------- main function --------------------------------

main_function(Main) --> main_function_header(), function_body(Body), { append(["\nBEGIN\n", Body, "END.\n"], Main) }.
main_function_header() --> function_header("main").

%-------------------------------- function body --------------------------------

function_body(Body) --> function_line(Line), "\n", function_body(BodyPart), { append(Line, BodyPart, Body) }.
function_body(Body) --> return_instruction(Return), "\n", { Body = Return }.

%--------------------------------- INSTRUCTION ---------------------------------

return_instruction(Return) --> maybe_whitespaces(), "ret", non_significant_thing(), { Return = "\n" }.
	
function_line(Line) --> non_significant_thing(), { Line = "" }.
%TODO real instructions

%------------------------------------ LABEL ------------------------------------

label(Name) --> maybe_whitespaces(), name(Name), ":", non_significant_thing(), "\n".

%------------------------------------ NAME -------------------------------------

name(Name) --> first_name_character(Char), rest_of_name(RestOfName), { append(Char, RestOfName, Name) }. %not sure if it is good - check assembler documentation
rest_of_name(Name) --> name_character(Char), rest_of_name(RestOfName), { append(Char, RestOfName, Name) }.
rest_of_name(Name) --> "", { Name = "" }.

name_character(Char) --> digit(Char) | first_name_character(Char).
first_name_character(Char) --> letter(Char) | other_name_character(Char).
other_name_character(Char) --> "_", { Char = "_" }.
other_name_character(Char) --> ".", { Char = "." }.

%----------------------------------- COMMENT -----------------------------------

end_non_significant_lines() --> non_significant_line(), end_non_significant_lines().
end_non_significant_lines() --> non_significant_thing().
non_significant_lines() --> non_significant_line(), non_significant_lines().
non_significant_lines() --> "".
non_significant_line() --> non_significant_thing(), "\n".

non_significant_thing() --> maybe_whitespaces(), maybe_comment().

maybe_comment() --> "" | comment().
comment() --> ";", comment_body().
comment_body() --> "" | no_newline_characters().

%--------------------------------- WHITESPACES ---------------------------------

maybe_whitespaces() --> "" | whitespaces().
whitespaces() --> whitespace(), whitespaces().
whitespaces() --> whitespace().
whitespace() --> " " | "\t".

%------------------------------- CHARACTER TYPES -------------------------------

letter(Letter) --> [LetterCode], { code_type(LetterCode, alpha), Letter = [LetterCode] }.

number(Number) --> digit(Digit), number(NumberPart), { append(Digit, NumberPart, Number) }.
number(Number) --> "", { Number = "" }.
digit(Digit) --> [DigitCode], { code_type(DigitCode, digit), Digit = [DigitCode] }.

no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { C \= '\n' }.
