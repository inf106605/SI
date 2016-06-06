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
	maybe_non_main_procedures(Procedures),
	non_significant_lines(),
	main_procedure(Main),
	end_non_significant_lines(),
	{ append([Header, Constants, Variables, Procedures, Main], Program) }.

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
variable_line(VariableLine) --> variable_label(Name), non_significant_lines(), maybe_whitespaces(), variable_type(Type), non_significant_thing(), "\n", { append(["\t", Name, " : ", Type, ";\n"], VariableLine) }.

% string
variable_type(Type) --> "resb", whitespaces(), "256", { Type = "string" }.
% byte
variable_type(Type) --> "resb", whitespaces(), "1", { Type = "byte" }.
% word
variable_type(Type) --> "resw", whitespaces(), "1", { Type = "word" }.
% double
variable_type(Type) --> "resd", whitespaces(), "1", { Type = "dword" }.

variable_label(Name) --> label([FirstChar|RestOfName]), { FirstChar\=95, append([FirstChar],RestOfName,Name) }.

%---------------------------------- CONSTANTS ----------------------------------

constants(Constants) --> constant_lines(ConstantLines), { append("\nCONST\n", ConstantLines, Constants) }.
constants(Constants) --> "", { Constants = "" }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), non_significant_lines(), constant_lines(RestOfConstantLines), { append(ConstantLine, RestOfConstantLines, ConstantLines) }.
constant_lines(ConstantLines) --> constant_line(ConstantLine), { ConstantLines = ConstantLine }.
constant_line(ConstantLine) --> constant_label(Name), non_significant_lines(), maybe_whitespaces(), constant_data(Data), non_significant_thing(), "\n", { append(["\t", Name, " = ", Data, ";\n"], ConstantLine) }.
constant_data(Data) --> constant_byte(Data).
constant_data(Data) --> constant_word(Data).
constant_data(Data) --> constant_dword(Data).
constant_data(Data) --> constant_string(Data).

constant_label(Name) --> label([FirstChar|RestOfName]), { FirstChar\=95, append([FirstChar],RestOfName,Name) }.

%------------------------------- string constant -------------------------------

constant_string(ConstantString) --> "db", whitespaces(), number(_), constant_string_parts(StringPart), { ConstantString = StringPart }.
constant_string_parts(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), number(Number), constant_string_parts(NextStringPart), { append(["#", Number, NextStringPart], StringPart) }.
constant_string_parts(StringPart) --> maybe_whitespaces(), ",", maybe_whitespaces(), string(String), constant_string_parts(NextStringPart), { append(["'", String, "'", NextStringPart], StringPart) }.
constant_string_parts(StringPart) --> "", { StringPart = "" }.

string(String) --> "'", string_part(StringPart), "'", { String = StringPart }.
string_part(StringPart) --> string_char(Char), string_part(NextStringPart), { append(Char, NextStringPart, StringPart) }.
string_part(StringPart) --> "", { StringPart = "" }.
string_char(Char) --> [C], { C \= 10, C \= 39, Char = [C] }.

%------------------------------- constant number -------------------------------

constant_byte(ConstantByte) --> "db", whitespaces(), number(Number), { ConstantByte = Number}.
constant_word(ConstantByte) --> "dw", whitespaces(), number(Number), { ConstantByte = Number}.
constant_dword(ConstantByte) --> "dd", whitespaces(), number(Number), { ConstantByte = Number}.

%--------------------------------- PROCEDURES ----------------------------------

maybe_non_main_procedures(Procedures) --> non_main_procedure(Procedure), non_significant_lines(), maybe_non_main_procedures(RestOfProcedures), { append(Procedure, RestOfProcedures, Procedures) }.
maybe_non_main_procedures(Procedures) --> "", { Procedures="" }.
non_main_procedure(Procedure) --> procedure_label([112|Name]), procedure_body(Body), { append(["\nprocedure ",Name,"();\nbegin\n",Body,"end;\n"], Procedure) }.

procedure_label(Name) --> label([95|Name]).

%------------------------------- main procedure --------------------------------

main_procedure(Main) --> main_procedure_header(), procedure_body(Body), { append(["\nBEGIN\n", Body, "END.\n"], Main) }.
main_procedure_header() --> procedure_label("main").

%------------------------------- procedure body --------------------------------

procedure_body(Body) --> block_body("", Body), non_significant_lines(), return_instruction().

block_body(Indent, Body) --> non_significant_line(), block_body(Indent, Body).
block_body(Indent, Body) --> instruction_set([9|Indent], Line), block_body(Indent, BodyPart), { append(Line, BodyPart, Body) }.
block_body(Indent, Body) --> "", { Body = "" }.

%--------------------------------- INSTRUCTION ---------------------------------

% Blocks
block(Indent, Block) --> instruction_set([9|Indent], Block).
block(Indent, Block) --> block_body(Indent, Body), { append([Indent,"begin\n",Body,Indent,"end;\n"], Block) }.

% Read
instruction_set(Indent, InstructionSet) --> procedure_call("_read_pascal_string", [Label], "4"), { append([Indent,"Read(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_read_uint8"), mov_to_var_instruction(Label, "al"), { append([Indent,"Read(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_read_uint16"), mov_to_var_instruction(Label, "ax"), { append([Indent,"Read(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_read_uint32"), mov_to_var_instruction(Label, "eax"), { append([Indent,"Read(",Label,");\n"], InstructionSet) }.
% Write
instruction_set(Indent, InstructionSet) --> procedure_call("_print_pascal_string", [Label], "4"), { append([Indent,"Write(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_println_pascal_string", [Label], "4"), { append([Indent,"Writeln(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_print_uint8", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Write(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_println_uint8", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Writeln(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_print_uint16", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Write(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_println_uint16", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Writeln(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_print_uint32", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Write(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_println_uint32", [LabelWithType], "4"), { append(["dword [", Label, "]"], LabelWithType), append([Indent,"Writeln(",Label,");\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> procedure_call("_println"), { append(Indent, "Writeln();\n", InstructionSet) }.
% Call procedure
instruction_set(Indent, InstructionSet) --> procedure_call([95,112|Name]), { append([Indent,Name,"();\n"], InstructionSet) }.
% Arithmetic
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(_, Label), non_significant_lines(), add_var_instruction(_,Label2), non_significant_lines(), mov_to_var_instruction(Label3,_), { append([Indent,Label3," := ",Label," + ",Label2,";\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(_, Label), non_significant_lines(), sub_var_instruction(_,Label2), non_significant_lines(), mov_to_var_instruction(Label3,_), { append([Indent,Label3," := ",Label," - ",Label2,";\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(Register, Label), non_significant_lines() inc_instruction(Register), 
	non_significant_lines(), mov_to_var_instruction(Label,Register), { append([Indent,Label," := ",Label," + ","1;\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(Register, Label), non_significant_lines(), dec_instruction(Register), non_significant_lines(), mov_to_var_instruction(Label,Register), { append([Indent,Label," := ",Label," - ","1;\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(Register, Label), non_significant_lines(), mul_instruction(Register), non_significant_lines(), mov_to_var_instruction(Label,Register), { append([Indent,Label," := ",Label," * ",Register,";\n"], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_from_var_instruction(Register, Label), non_significant_lines(), div_instruction(Register), non_significant_lines(), mov_to_var_instruction(Label,Register), { append([Indent,Label," := ",Label," / ",Register,";\n"], InstructionSet) }.
% Loops
instruction_set(Indent, InstructionSet) --> mov_instruction("ecx",StartValue), non_significant_lines(), label(Label), non_significant_lines(), mov_to_var_instruction(Counter, "ecx"),
	non_significant_lines(), block(Indent, Block), non_significant_lines(),
	mov_from_var_instruction("ecx", Counter), non_significant_lines(), inc_instruction("ecx"), non_significant_lines(), cmp_instruction("ecx", EndValue), non_significant_lines(), jle_instruction(Label),
	{ append([Indent,"for ",Counter," := ",StartValue," to ",EndValue," do\n",Block], InstructionSet) }.
instruction_set(Indent, InstructionSet) --> mov_instruction("ecx",StartValue), non_significant_lines(), label(Label), non_significant_lines(), mov_to_var_instruction(Counter, "ecx"),
	non_significant_lines(), block(Indent, Block), non_significant_lines(),
	mov_from_var_instruction("ecx", Counter), non_significant_lines(), dec_instruction("ecx"), non_significant_lines(), cmp_instruction("ecx", EndValue), non_significant_lines(), jge_instruction(Label),
	{ append([Indent,"for ",Counter," := ",StartValue," downto ",EndValue," do\n",Block], InstructionSet) }.

procedure_call(ProcedureName) --> call_instruction(ProcedureName).
procedure_call(ProcedureName, Params, StackSpace) --> push_parameters(Params), non_significant_lines(), call_instruction(ProcedureName), non_significant_lines(), release_stack_instruction(StackSpace).
push_parameters([Param|Params]) --> push_instruction(Param), non_significant_lines(), push_parameters(Params).
push_parameters([Param]) --> push_instruction(Param).

%--------------------------- assembler instructions ----------------------------

mov_from_var_instruction(Param1, Param2) --> mov_instruction(Param1, Var), { append(["[",Param2,"]"], Var) }.
mov_to_var_instruction(Param1, Param2) --> mov_instruction(Var, Param2), { append(["[",Param1,"]"], Var) }.
mov_instruction(Param1, Param2) --> instruction("mov", [Param1,Param2]).
push_instruction(Param) --> instruction("push", [Param]).
pop_instruction(Param) --> instruction("pop", [Param]).
call_instruction(Param) --> instruction("call", [Param]).
release_stack_instruction(Param) --> add_instruction("esp", Param).
add_var_instruction(Param1, Param2) --> add_instruction(Param1, Var), { append(["[",Param2,"]"], Var) }.
add_instruction(Param1, Param2) --> instruction("add", [Param1,Param2]).
sub_var_instruction(Param1, Param2) --> sub_instruction(Param1, Var), { append(["[",Param2,"]"], Var) }.
sub_instruction(Param1, Param2) --> instruction("sub", [Param1,Param2]).
mul_instruction(Param) --> instruction("mul", [Param]).
div_instruction(Param) --> instruction("div", [Param]).
dec_instruction(Param) --> instruction("dec", [Param]).
inc_instruction(Param) --> instruction("inc", [Param]).
cmp_instruction(Param1, Param2) --> instruction("cmp", [Param1,Param2]).
jle_instruction(Param) --> instruction("jle", [Param]).
jge_instruction(Param) --> instruction("jge", [Param]).
return_instruction() --> instruction("ret", []).


instruction(Instruction, Params) --> maybe_whitespaces(), name(Instruction), parameters(Params), non_significant_thing(), "\n".
parameters([]) --> "".
parameters(Params) --> whitespaces(), a_parameters(Params).
a_parameters([Param|Params]) --> maybe_whitespaces(), parameter(Param), maybe_whitespaces(), ",", a_parameters(Params).
a_parameters([Param]) --> maybe_whitespaces(), parameter(Param).
parameter(Param) --> non_white_parameter_character(Char), rest_of_parameter(RestOfParam), { append(Char, RestOfParam, Param) }.
rest_of_parameter(Param) --> parameter_character(Char), rest_of_parameter(RestOfParam), { append(Char, RestOfParam, Param) }.
rest_of_parameter(Param) --> "", { Param="" }.
parameter_character(Char) --> non_white_parameter_character(Char).
parameter_character(Char) --> " ", { Char = " " }.
non_white_parameter_character(Char) --> name_character(Char).
non_white_parameter_character(Char) --> "[", { Char = "[" }.
non_white_parameter_character(Char) --> "]", { Char = "]" }.

%------------------------------------ LABEL ------------------------------------

internal_label(Name) --> label(46|Name).
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
number(Number) --> digit(Digit), { Number = Digit }.
digit(Digit) --> [DigitCode], { code_type(DigitCode, digit), Digit = [DigitCode] }.

no_newline_characters() --> no_newline_character(), no_newline_characters().
no_newline_characters() --> no_newline_character().
no_newline_character() --> [C], { C \= 10 }.
