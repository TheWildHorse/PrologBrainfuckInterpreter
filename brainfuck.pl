% Grammar Definition
parse(left) --> "<".
parse(right) --> ">".
parse(add) --> "+".
parse(sub) --> "-".
parse(output) --> ".".
parse(input) --> ",".
% Each loop contains another operationstack of instructions enclosed in [ ]
parse(loop(Instructions)) --> "[", operationstack(Instructions), "]".
operationstack([]) --> "".
operationstack([I|L]) --> parse(I), operationstack(L).

% Language interpretation logic
% Implements the > BF operator
runRight() :- 
	currentPosition(X),
	retractall(currentPosition(_)), % Removes the currentPosition fact
	SUM is (X+1) mod 30000, % Calculates the new position from the previous one
	asserta(currentPosition(SUM)). % Adds a fact with the new position value
% Implements the < BF operator
runLeft() :-
	currentPosition(X),
	retractall(currentPosition(_)), % Removes the currentPosition fact
	SUM is (X-1) mod 30000, % Calculates the new position from the previous one
	asserta(currentPosition(SUM)). % Adds a fact with the new position value
% Implements the + BF operator
runIncrement() :-
	currentPosition(X),
	% Finds the value of the memory strip at the current location, if it has no value it is assigned a 0
	(memoryStrip(X, _) -> memoryStrip(X, Current); Current is 0),
	retractall(memoryStrip(X,_)), % Remove the memory strip fact for the current position
	SUM is (Current+1) mod 256, % Calculates the new value based on the previous one
	asserta(memoryStrip(X, SUM)). % Adds a fact storing the new value on the memory strip
% Implements the - BF operator
runDecrement() :-
	currentPosition(X),
	% Finds the value of the memory strip at the current location, if it has no value it is assigned a 0
	(memoryStrip(X, _) -> memoryStrip(X, Current); Current is 0),
	retractall(memoryStrip(X,_)), % Remove the memory strip fact for the current position
	SUM is (Current-1) mod 256, % Calculates the new value based on the previous one
	asserta(memoryStrip(X, SUM)). % Adds a fact storing the new value on the memory strip
% Implements the . BF operator
runOutput() :-
	currentPosition(Pos),
	memoryStrip(Pos, Code), % Finds the value of the cell at the current position
	char_code(Output, Code), % Finds a character belonging to that ASCII value
	write(Output). % Prints it to the console
% Implements the , BF operator
runInput() :-
	get_single_char(Code), % Gets a single char from the console
	currentPosition(Pos),
	retractall(memoryStrip(Pos, _)), % Removes memory strip value for the current position
	asserta(memoryStrip(Pos, Code)). % Adds a new memory strip value that the user entered

% List is empty? We are done
interpretInstructionList([]) :- true.
% Interpret the instruction on the HEAD of the list, and then process the rest of the list
interpretInstructionList([C|R]) :- interpretInstruction(C), interpretInstructionList(R).
% Run the corresponding instruction predicate for each instruction
interpretInstruction(left) :- runLeft().
interpretInstruction(right) :- runRight().
interpretInstruction(add) :- runIncrement().
interpretInstruction(sub) :- runDecrement().
interpretInstruction(input) :- runInput().
interpretInstruction(output) :- runOutput().
% Loop running condiion
interpretInstruction(loop(_)) :-
	currentPosition(Pos),
	memoryStrip(Pos, 0), % Is the value of the current position 0
	true. % No need to run it again
interpretInstruction(loop(Instructions)) :- 
	interpretInstructionList(Instructions), % Run instructions inside the loop
	interpretInstruction(loop(Instructions)). % Run the loop execution logic again


% Execution

% Set the inital values for the interpreter.
:- asserta(currentPosition(0)),
asserta(memoryStrip(0, 0)).

% Interprets a Program given in a string
interpret(Program) :-
	string_codes(Program,ProgramCodes), % Split string characters into a list of ASCII values
	operationstack(Instructions, ProgramCodes, []), % Parse the characters to BF operations
	interpretInstructionList(Instructions). % Interpret all instructions


% Debug commands

% Prints the parsed BF program operations
parseAndPrint(Program) :-
	string_codes(Program,ProgramCodes),
	operationstack(Instructions, ProgramCodes, []),
	write(Instructions).

% Prints the current memory strip location
readPos() :- currentPosition(Pos), write(Pos).

% Prints the value at the current memory strip location
readMem() :- currentPosition(Pos), memoryStrip(Pos, X), write(X).




