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
program_header_global_line() --> maybe_whitespaces(), "global", whitespaces(), name(), non_significant_thing(), "\n".
program_header_extern_line() --> maybe_whitespaces(), "extern", whitespaces(), name(), non_significant_thing(), "\n".
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

name() --> non_digit_name_character(), rest_of_name(). %not sure if it is good - check assembler documentation
rest_of_name() --> name_character(), rest_of_name().
rest_of_name() --> "".

name_character() --> digit() | non_digit_name_character().
non_digit_name_character --> letter() | "_" | ".".

letter() --> [Letter], { code_type(Letter, alpha) }.

digit() --> "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9".

maybe_no_newline_characters() --> "" | no_newline_characters().
no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { not(head_is_the_same([C], "\n")) }.

head_is_the_same([H1|_], [H2|_]) :- H1 == H2.
