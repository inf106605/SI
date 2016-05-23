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
	maybe_bss_section(),
	non_significant_lines(),
	variables(Variables),
	non_significant_lines(),
	text_section(),
	non_significant_lines(),
	constants(Constants),
	non_significant_lines(),
	main_function(Main),
	end_non_significant_lines(),
	{ append([Header, Constants, Variables, Main], Program) }.

%----------------------------------- HEADER ------------------------------------

program_header(Header) --> program_header_lines(), { Header = "PROGRAM Prog;\n" }.
program_header_lines() --> program_header_line(), program_header_lines().
program_header_lines() --> "".
program_header_line() --> non_significant_line() | program_header_global_line() | program_header_extern_line().
program_header_global_line() --> maybe_whitespaces(), "global", whitespaces(), name(_), non_significant_thing(), "\n".
program_header_extern_line() --> maybe_whitespaces(), "extern", whitespaces(), name(_), non_significant_thing(), "\n".

%----------------------------------- HEADER ------------------------------------

maybe_bss_section() --> "" | maybe_whitespaces(), section("bss").
text_section() --> maybe_whitespaces(), section("text").
section(Section) --> maybe_whitespaces(), "section", whitespaces(), ".", name(Section), non_significant_thing(), "\n".

%---------------------------------- VARIABLES ----------------------------------

variables(Variables) --> variable_lines(VariableLines), { append("\nVAR\n", VariableLines, Variables) }.
variables(Variables) --> "", { Variables = "" }.
variable_lines(VariableLines) --> variable_line(VariableLine), non_significant_lines(), variable_lines(RestOfVariableLines), { append(VariableLine, RestOfVariableLines, VariableLines) }.
variable_lines(VariableLines) --> variable_line(VariableLine), { VariableLines = VariableLine }.
variable_line(VariableLine) --> label(Name), non_significant_lines(), maybe_whitespaces(), variable_type(Type), non_significant_thing(), "\n", { append(["\t", Name, " : ", Type, ";\n"], VariableLine) }.

% string
variable_type(Type) --> "resb", whitespaces(), "256", { Type = "string" }.
% byte
variable_type(Type) --> "resb", whitespaces(), "1", { Type = "byte" }.
% word
variable_type(Type) --> "resw", whitespaces(), "1", { Type = "word" }.
% double
variable_type(Type) --> "resd", whitespaces(), "1", { Type = "double" }.

%---------------------------------- CONSTANTS ----------------------------------

constants(Constants) --> constant_lines(ConstantLines), { append("\nCONST\n", ConstantLines, Constants) }.
constants(Constants) --> "", { Constants = "" }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), non_significant_lines(), constant_lines(RestOfConstantLines), { append(ConstantLine, RestOfConstantLines, ConstantLines) }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), { ConstantLines = ConstantLine }.
constant_line(ConstantLine) --> label(Name), non_significant_lines(), maybe_whitespaces(), constant_data(Data), non_significant_thing(), "\n", { append(["\t", Name, " = ", Data, ";\n"], ConstantLine) }.
constant_data(Data) --> constant_string(Data).
%TODO more types

%------------------------------- string constant -------------------------------

constant_string(ConstantString) --> "db", whitespaces(), number(_), constant_string_parts(StringPart), { ConstantString = StringPart }.
constant_string_parts(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), number(Number), constant_string_parts(NextStringPart), { append(["#", Number, NextStringPart], StringPart) }.
constant_string_parts(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), string(String), constant_string_parts(NextStringPart), { append(["'", String, "'", NextStringPart], StringPart) }.
constant_string_parts(StringPart) --> "", { StringPart = "" }.

string(String) --> "'", string_part(StringPart), "'", { String = StringPart }.
string_part(StringPart) --> string_char(Char), string_part(NextStringPart), { append(Char, NextStringPart, StringPart) }.
string_part(StringPart) --> "", { StringPart = "" }.
string_char(Char) --> [C], { C \= 10, C \= 39, Char = [C] }.

%---------------------------------- FUNCTIONS ----------------------------------

function_header(Name) --> function_label([95|Name]).

function_label(Name) --> label(Name).

%-------------------------------- main function --------------------------------

main_function(Main) --> main_function_header(), function_body(Body), { append(["\nBEGIN\n", Body, "END.\n"], Main) }.
main_function_header() --> function_header("main").

%-------------------------------- function body --------------------------------

function_body(Body) --> non_significant_line(), function_body(Body).
function_body(Body) --> instruction_set("\t", Line), function_body(BodyPart), { append(Line, BodyPart, Body) }.
function_body(Body) --> return_instruction(), { Body = "" }.

%--------------------------------- INSTRUCTION ---------------------------------

% Write string
instruction_set(Indent, InstructionSet) --> function_call("_print_pascal_string", [Label], "4"), { append([Indent,"Write(",Label,");\n"], InstructionSet) }.
%TODO more instructions

function_call(FunctionName) --> call_instruction(FunctionName).
function_call(FunctionName, Params, StackSpace) --> push_parameters(Params), non_significant_lines(), call_instruction(FunctionName), non_significant_lines(), release_stack_instruction(StackSpace).
push_parameters([Param|Params]) --> push_instruction(Param), non_significant_lines(), push_parameters(Params).
push_parameters([Param]) --> push_instruction(Param).

%--------------------------- assembler instructions ----------------------------

push_instruction(Param) --> instruction("push", [Param]).
call_instruction(Param) --> instruction("call", [Param]).
release_stack_instruction(Param) --> add_instruction("esp", Param).
add_instruction(Param1, Param2) --> instruction("add", [Param1,Param2]).
return_instruction() --> instruction("ret", []).

instruction(Instruction, Params) --> maybe_whitespaces(), name(Instruction), parameters(Params), non_significant_thing(), "\n".
parameters([]) --> "".
parameters(Params) --> whitespaces(), a_parameters(Params).
a_parameters([Param|Params]) --> maybe_whitespaces(), name_or_number(Param), maybe_whitespaces(), ",", a_parameters(Params).
a_parameters([Param]) --> maybe_whitespaces(), name_or_number(Param).

%------------------------------------ LABEL ------------------------------------

label(Name) --> maybe_whitespaces(), name(Name), ":", non_significant_thing(), "\n".

%------------------------------------ NAME -------------------------------------

name_or_number(NameOrNumber) --> name(NameOrNumber).
name_or_number(NameOrNumber) --> number(NameOrNumber).

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
number(Number) --> digit(Digit), { Number = Digit }.
digit(Digit) --> [DigitCode], { code_type(DigitCode, digit), Digit = [DigitCode] }.

no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { C \= 10 }.
