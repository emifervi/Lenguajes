/* Elemento k */
elemento_k(0, [Head|_], Head).
elemento_k(Pos, [_|Tail], Elem) :- Npos is Pos-1, elemento_k(Npos, Tail, Elem).

/* Rango */
rango(S, S, [S]).
rango(S, F, [S|Tail]) :- S =< F, Elem is S + 1, rango(Elem, F, Tail).

/* Duplica D */
duplicaD([X], 1, [X]).
duplicaD([X], D, [X|Tail]) :- Step is D - 1, Step > 0, duplicaD([X], Step, Tail), !.
duplicaD([Head|Tail], D, Li) :- 
    duplicaD([Head], D, Subl),
    duplicaD(Tail, D, SubLi),
    append(Subl, SubLi, Li).

/* Intercala */
intercala([], [], []).
intercala([X|Xs], [Y|Ys], [X,Y|Tail]) :- intercala(Xs, Ys, Tail).