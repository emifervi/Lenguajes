""" 
Emilio Fernando Alonso Villa
A00959385
Tarea 2 
"""
import string
from enum import IntEnum
from anytree import Node, RenderTree


class Symbol(IntEnum):
    Bool = 0
    Letter = 1
    Number = 2
    Operator = 3
    Whitespace = 4
    OpenList = 5
    OpenParen = 6
    CloseParen = 7


charset_symbol = {
    Symbol.Bool: ['#t', '#f'],
    Symbol.Letter: string.ascii_letters,
    Symbol.Number: string.digits,
    Symbol.Operator: ['+', '-', '*', '/', '%', '='],
    Symbol.Whitespace: string.whitespace,
    Symbol.OpenList: ["'("],
    Symbol.OpenParen: ['('],
    Symbol.CloseParen: [')']
}


def char_to_symbol(char):
    for charset in charset_symbol:
        if char in charset_symbol[charset]:
            return charset
    return None


class State(IntEnum):
    Zero = 0
    One = 1     # Parentesis Abierto
    Two = 2     # Identificadores
    Three = 3   # Operadores
    Four = 4    # Literales Enteras
    Five = 5    # Bools
    Six = 6     # Listas
    Error = 7


class Action(IntEnum):
    Shift = 0
    Reduce = 1
    Dispose = 2

# Inicializar con errores
rows = range(len(State))
cols = range(len(Symbol))
tt = [[(State.Error, Action.Dispose) for col in cols] for row in rows]

# Estado 0 - Comiendo espacios en blanco
tt[State.Zero][Symbol.Whitespace] = (State.Zero, Action.Shift)
tt[State.Zero][Symbol.CloseParen] = (State.Zero, Action.Reduce)
tt[State.Zero][Symbol.OpenParen] = (State.One, Action.Dispose)
tt[State.Zero][Symbol.Letter] = (State.Two, Action.Dispose)
tt[State.Zero][Symbol.Operator] = (State.Three, Action.Dispose)
tt[State.Zero][Symbol.Number] = (State.Four, Action.Dispose)
tt[State.Zero][Symbol.Bool] = (State.Five, Action.Dispose)
tt[State.Zero][Symbol.OpenList] = (State.Six, Action.Dispose)

# Estado 1 - Reconociendo funciones
tt[State.One][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.One][Symbol.Letter] = (State.Two, Action.Reduce)
tt[State.One][Symbol.Operator] = (State.Three, Action.Reduce)

# Estado 2 - Reconociendo identificadores
tt[State.Two][Symbol.CloseParen] = (State.Zero, Action.Reduce)
tt[State.Two][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Two][Symbol.Letter] = (State.Two, Action.Shift)
tt[State.Two][Symbol.Number] = (State.Two, Action.Shift)
tt[State.Two][Symbol.OpenParen] = (State.One, Action.Reduce)
tt[State.Two][Symbol.OpenList] = (State.Six, Action.Reduce)

# Estado 3 - Reconociendo operadores
tt[State.Three][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Three][Symbol.OpenParen] = (State.One, Action.Reduce)
tt[State.Three][Symbol.Letter] = (State.Two, Action.Reduce)
tt[State.Three][Symbol.Number] = (State.Four, Action.Reduce)
tt[State.Three][Symbol.Bool] = (State.Five, Action.Reduce)
tt[State.Three][Symbol.OpenList] = (State.Six, Action.Reduce)

# Estado 4 - Reconociendo Literales Enteras
tt[State.Four][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Four][Symbol.CloseParen] = (State.Zero, Action.Reduce)
tt[State.Four][Symbol.OpenParen] = (State.One, Action.Reduce)
tt[State.Four][Symbol.Number] = (State.Four, Action.Shift)
tt[State.Four][Symbol.Bool] = (State.Five, Action.Reduce)
tt[State.Four][Symbol.OpenList] = (State.Six, Action.Reduce)

# Estado 5 - Reconociendo Bool
tt[State.Five][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Five][Symbol.CloseParen] = (State.Zero, Action.Reduce)
tt[State.Five][Symbol.OpenParen] = (State.One, Action.Reduce)
tt[State.Five][Symbol.Letter] = (State.Two, Action.Reduce)
tt[State.Five][Symbol.Number] = (State.Four, Action.Reduce)
tt[State.Four][Symbol.OpenList] = (State.Six, Action.Reduce)

#Estado 6 - Reconociendo Listas
tt[State.Six][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Six][Symbol.CloseParen] = (State.Zero, Action.Reduce)
tt[State.Six][Symbol.OpenParen] = (State.One, Action.Reduce)
tt[State.Six][Symbol.Letter] = (State.Two, Action.Reduce)
tt[State.Six][Symbol.Number] = (State.Four, Action.Reduce)
tt[State.Six][Symbol.Bool] = (State.Five, Action.Reduce)
tt[State.Six][Symbol.OpenList] = (State.Six, Action.Shift)


class Token(IntEnum):
    Identifier = 0
    Number = 1
    Operator = 2
    OpenParen = 3
    CloseParen = 4
    OpenList = 5
    Bool = 6
    ERROR = 7


def scan(source_code, state=State.Zero, char_buffer=[]):
    tokens = []
    for i in range(len(source_code)):
        char = source_code[i]
        if(char == '#' and (source_code[i + 1] == 'f' or 't')):
            char = char + source_code[i + 1]
        
        if((source_code[i] == 'f' or 't') and source_code[i - 1] == '#'):
            continue
        
        if(char == "'" and (source_code[i + 1] == '(')):
            char = char + source_code[i + 1]
        
        if((source_code[i] == '(' and source_code[i - 1] == "'")):
            continue

        symbol = char_to_symbol(char)
        (next_state, action) = tt[state][symbol]

        if next_state == State.Error:
            return 'ERROR'

        if action == Action.Dispose:
            char_buffer.clear()
        elif action == Action.Reduce:
            if state == State.One:
                tokens.append((Token.OpenParen, ''.join(char_buffer)))
            elif state == State.Two:
                tokens.append((Token.Identifier, ''.join(char_buffer)))
            elif state == State.Three:
                tokens.append((Token.Operator, ''.join(char_buffer)))
            elif state == State.Four:
                tokens.append((Token.Number, ''.join(char_buffer)))
            elif state == State.Five:
                tokens.append((Token.Bool, ''.join(char_buffer)))
            elif state == State.Six:
                tokens.append((Token.OpenList, ''.join(char_buffer)))
            elif state == State.Zero:
                tokens.append((Token.CloseParen, ''.join(char_buffer)))

            char_buffer.clear()

        char_buffer.append(char)
        state = next_state

    if state == State.Zero:
        tokens.append((Token.CloseParen, ''.join(char_buffer)))

    return tokens

def match(token, tokens):
    if tokens and token == tokens[0]:
        tokens.pop(0)
        return True

    return False

def exp(tokens, parent_node):
    if not tokens:
        return

    elif match(Token.OpenParen, tokens):
        exp_node = Node('EXP', parent=parent_node)
        Node('OPEN_PAREN', parent=exp_node)
        func(tokens, exp_node)
        if match(Token.CloseParen, tokens):
            Node('CLOSE_PAREN', parent=exp_node)
            params(tokens, exp_node)
        else:
            tokens.append('Falta cierre de parentesis')

def func(tokens, parent_node):
    if not tokens:
        return

    if match(Token.Identifier, tokens):
        func_node = Node('FUNC', parent=parent_node)
        Node('ID', parent=func_node)
        params(tokens, parent_node)
    elif match(Token.Operator, tokens):
        func_node = Node('FUNC', parent=parent_node)
        Node('OP', parent=func_node)
        params(tokens, parent_node)

def params(tokens, parent_node):
    if not tokens:
        return
    
    if(Token.OpenList == tokens[0]):
        params_node = Node('PARAMS', parent=parent_node)
        listas(tokens, params_node)
    elif(Token.OpenParen == tokens[0]):
        params_node = Node('PARAMS', parent=parent_node)
        exp(tokens, params_node)
    elif match(Token.Identifier, tokens):
        params_node = Node('PARAMS', parent=parent_node)
        Node('ID', parent=params_node)
        if tokens[0] != Token.CloseParen:
            params(tokens, params_node)
        exp(tokens, params_node)
    elif match(Token.Number, tokens):
        params_node = Node('PARAMS', parent=parent_node)
        Node('INT', parent=params_node)
        if tokens[0] != Token.CloseParen:
            params(tokens, params_node)
        exp(tokens, params_node)
    elif match(Token.Bool, tokens):
        params_node = Node('PARAMS', parent=parent_node)
        Node('BOOL', parent=params_node)
        if tokens[0] != Token.CloseParen:
            params(tokens, params_node)
        exp(tokens, params_node)

def listas(tokens, parent_node):
    if not tokens:
        return
    
    if match(Token.OpenList, tokens):
        list_node = Node('LIST', parent=parent_node)
        Node('OPEN_QUOTE_LIST', parent=list_node)
        params(tokens, list_node)
    if match(Token.CloseParen, tokens):
        Node('ClOSE_QUOTE_LIST', parent=list_node)
        exp(tokens, list_node)
    else:
        tokens.append('Falta cierre de parentesis')


def parse(tokens, parse_tree=None):
    root = Node('PROGRAM')
    exp(tokens, root)

    if tokens:
        print(f'ERROR {tokens}')
        return None
    else:
        print('AWESOME')
        for pre, fill, node in RenderTree(root):
            print("%s%s" % (pre, node.name))
        return parse_tree

def only_tokens(token_tuples):
    return [t[0] for t in token_tuples]

test1 = "(= #t hola)"
# print('\n'.join(map(str, scan(test1))))
print(f'test: {test1}')
print('\n');
# print('\n'.join(map(str, only_tokens(scan(test1)))))
# print('\n');
parse(only_tokens(scan(test1)))

