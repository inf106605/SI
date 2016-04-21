%load input and save output
main :-
	read_lines(Asm),
	translate(Asm, Pas),
	write_lines(Pas),
	expr(Z, "-2+3*5+1", []),
	write(Z),
	halt.

%read stdin
read_lines([H|T]) :-
	read_line_to_codes(user_input, H), H \= end_of_file, read_lines(T).
read_lines([]).

%write to stdout
write_lines([]).
write_lines([H|T]) :-
	writef("%s\n", [H]), write_lines(T).

%-------------------------------------------------------------------------------

%translate
translate(Asm, Pas) :-
	Asm = Pas.

%example
expr(Z) --> term(X), "+", expr(Y), {Z is X + Y}.
expr(Z) --> term(X), "-", expr(Y), {Z is X - Y}.
expr(X) --> term(X).

term(Z) --> number(X), "*", term(Y), {Z is X * Y}.
term(Z) --> number(X), "/", term(Y), {Z is X / Y}.
term(Z) --> number(Z).

number(C) --> "+", number(C).
number(C) --> "-", number(X), {C is -X}.
number(X) --> [C], {"0"=<C, C=<"9", X is C - "0"}.
