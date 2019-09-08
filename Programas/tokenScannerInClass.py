import string
from enum import IntEnum
from anytree import Node, RenderTree


class Symbol(IntEnum):
    Letter = 0
    Number = 1
    Operator = 2
    Whitespace = 3
    Delimiter = 4
    OpenParen = 5
    CloseParen = 6


charset_symbol = {
    Symbol.Letter: string.ascii_letters,
    Symbol.Number: string.digits,
    Symbol.Operator: ['+', '-', '*', '/', '%', '='],
    Symbol.Whitespace: string.whitespace,
    Symbol.Delimiter: [';'],
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
    One = 1     # Identificadores
    Two = 2     # Literales Enteras
    Three = 3   # Operadores
    Four = 4    # Parentesis Abierto
    Five = 5    # Parentesis Cerrado
    Error = 6


class Action(IntEnum):
    Shift = 0
    Reduce = 1
    Dispose = 2

# Inicializar con errores
rows = range(len(State))
cols = range(len(Symbol))
tt = [[(State.Error, Action.Dispose) for col in cols] for row in rows]

# EXP -> INT EXP1 | ( EXP ) EXP1
# EXP1 -> e | OP EXP
# OP -> + | - | * | % | =


# Estado 0 - Comiendo espacios en blanco
tt[State.Zero][Symbol.Letter] = (State.One, Action.Dispose)
tt[State.Zero][Symbol.Number] = (State.Two, Action.Dispose)
tt[State.Zero][Symbol.Whitespace] = (State.Zero, Action.Shift)
tt[State.Zero][Symbol.Operator] = (State.Three, Action.Dispose)
tt[State.Zero][Symbol.OpenParen] = (State.Four, Action.Dispose)
tt[State.Zero][Symbol.CloseParen] = (State.Five, Action.Dispose)

# Estado 1 - Reconociendo identificadores
tt[State.One][Symbol.Letter] = (State.One, Action.Shift)
tt[State.One][Symbol.Number] = (State.One, Action.Shift)
tt[State.One][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.One][Symbol.Operator] = (State.Three, Action.Reduce)
tt[State.One][Symbol.CloseParen] = (State.Five, Action.Reduce)

# Estado 2 - Reconociendo literales enteras
tt[State.Two][Symbol.Number] = (State.Two, Action.Shift)
tt[State.Two][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Two][Symbol.Delimiter] = (State.Zero, Action.Reduce)
tt[State.Two][Symbol.Operator] = (State.Three, Action.Reduce)
tt[State.Two][Symbol.CloseParen] = (State.Five, Action.Reduce)

# Estado 3 - Reconociendo operadores
tt[State.Three][Symbol.Number] = (State.Two, Action.Reduce)
tt[State.Three][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Three][Symbol.Letter] = (State.One, Action.Reduce)

# Estado 4 - Reconociendo parentesis abierto
tt[State.Four][Symbol.Number] = (State.Two, Action.Reduce)
tt[State.Four][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Four][Symbol.Letter] = (State.One, Action.Reduce)

# Estado 5 - Reconociendo parentesis cerrado
tt[State.Five][Symbol.Operator] = (State.Three, Action.Reduce)
tt[State.Five][Symbol.Whitespace] = (State.Zero, Action.Reduce)
tt[State.Five][Symbol.CloseParen] = (State.Five, Action.Reduce)

class Token(IntEnum):
    Identifier = 0
    Number = 1
    Operator = 2
    OpenParen = 3
    CloseParen = 4
    ERROR = 5


def scan(source_code, state=State.Zero, char_buffer=[]):
    tokens = []
    source_code += ' ' #Añadiendo un espacio en blanco adicional para reconocer EOF y no crear otro estado
    for char in source_code:
        symbol = char_to_symbol(char)
        (next_state, action) = tt[state][symbol]

        if next_state == State.Error:
            return 'ERROR'

        if action == Action.Dispose:
            char_buffer.clear()
        elif action == Action.Reduce:
            if state == State.One:
                tokens.append((Token.Identifier, ''.join(char_buffer)))
            elif state == State.Two:
                tokens.append((Token.Number, ''.join(char_buffer)))
            elif state == State.Three:
                tokens.append((Token.Operator, ''.join(char_buffer)))
            elif state == State.Four:
                tokens.append((Token.OpenParen, ''.join(char_buffer)))
            elif state == State.Five:
                tokens.append((Token.CloseParen, ''.join(char_buffer)))

            char_buffer.clear()

        char_buffer.append(char)
        state = next_state

    return tokens

# EXP -> EXP OP EXP | INT | ( EXP )
# OP -> + | - | * | % | =

# EXP -> INT EXP1 | ( EXP ) EXP1
# EXP1 -> e | OP EXP
# OP -> + | - | * | % | =

def match(token, tokens):
    if tokens and token == tokens[0]:
        tokens.pop(0)
        return True

    return False


def exp(tokens, parent_node):
    if match(Token.Number, tokens):
        exp_node = Node('EXP', parent=parent_node)
        Node('NUMBER', parent=exp_node)
        exp1(tokens, exp_node)
    elif match(Token.Identifier, tokens):
        exp_node = Node('EXP', parent=parent_node)
        Node('IDENTIFIER', parent=exp_node)
        exp1(tokens, exp_node)
    elif match(Token.OpenParen, tokens):
        exp_node = Node('EXP', parent=parent_node)
        Node('OPEN_PAREN', parent=exp_node)
        exp(tokens, exp_node)
        if match(Token.CloseParen, tokens):
            Node('CLOSE_PAREN', parent=exp_node)
            exp1(tokens, exp_node)
        else:
            tokens.append('Esperaba un cierre de paréntesis')
    else:
        tokens.append('Esperaba un número o inicio de paréntesis')


def exp1(tokens, parent_node):
    if not tokens:
        return

    if match(Token.Operator, tokens):
        exp1_node = Node('EXP1', parent=parent_node)
        Node('OPERATOR', parent=exp1_node)
        exp(tokens, exp1_node)


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

test1 = 'asdf = (10    - 5) * ( 9 / 7 * ( 4 * 5)) + r'

#print(scan(test1))
#print('\n');
#print(only_tokens(scan(test1)))
#print('\n');
parse(only_tokens(scan(test1)))
