%% Interop sample: a small family tree that is queried from Python with PySwip.
%%
%% Only `parent/2` and the gender facts are asserted; every other relation is
%% derived, so the Python side can ask high-level questions directly.

parent(john, doe).
parent(john, mark).
parent(doe, jane).
parent(mark, jane).
parent(doe, tom).

male(john).
male(mark).
male(tom).
female(doe).
female(jane).

%% father(?Father, ?Child)
father(Father, Child) :-
    parent(Father, Child),
    male(Father).

%% mother(?Mother, ?Child)
mother(Mother, Child) :-
    parent(Mother, Child),
    female(Mother).

%% sibling(?One, ?Other) - share at least one parent.
sibling(One, Other) :-
    parent(Parent, One),
    parent(Parent, Other),
    One \= Other.

%% ancestor(?Ancestor, ?Descendant)
ancestor(Ancestor, Descendant) :-
    parent(Ancestor, Descendant).
ancestor(Ancestor, Descendant) :-
    parent(Ancestor, Intermediate),
    ancestor(Intermediate, Descendant).

