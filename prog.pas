PROGRAM Prog;

CONST
	msg : string = 'Hello, World!'#10;

BEGIN
	Write(msg);
	Writeln(Shortint($FFFFFF9A));
	Writeln(Byte($FFFFFF9A));
	Writeln(Smallint($FFFFFF9A));
	Writeln(Word($FFFFFF9A));
	Writeln(Longint($FFFFFF9A));
	Writeln(Longword($FFFFFF9A));
END.
