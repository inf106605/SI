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
	main_function(Main),
	end_non_significant_lines(),
	{ append(Header, Main, Program) }.

program_header(Header) --> program_header_lines(), last_program_header_line(), { Header = "PROGRAM Prog;\n" }.
program_header_lines() --> program_header_line(), program_header_lines().
program_header_lines() --> "".
program_header_line() --> non_significant_line() | program_header_global_line() | program_header_extern_line().
program_header_global_line() --> maybe_whitespaces(), "global", whitespaces(), name(_), non_significant_thing(), "\n".
program_header_extern_line() --> maybe_whitespaces(), "extern", whitespaces(), name(_), non_significant_thing(), "\n".
last_program_header_line() --> maybe_whitespaces(), "section", whitespaces(),".text", non_significant_thing(), "\n".

main_function(Main) --> main_function_header(), function_body(Body), { append(["\nBEGIN\n", Body, "END.\n"], Main) }.

main_function_header() --> maybe_whitespaces(), "_main:", maybe_whitespaces(), "\n".

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

letter(Letter) --> [LetterCode], { code_type(LetterCode, alpha), Letter = [LetterCode] }.
digit(Digit) --> [DigitCode], { code_type(DigitCode, digit), Digit = [DigitCode] }.

maybe_no_newline_characters() --> "" | no_newline_characters().
no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { not(head_is_the_same([C], "\n")) }.

head_is_the_same([H1|_], [H2|_]) :- H1 == H2.
