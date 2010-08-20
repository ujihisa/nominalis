require 'strscan'

def nominalis(code)
  s = StringScanner.new code
  tokens = []
  until s.eos?
    tokens <<
      case
      when s.scan(/class|function|if|else|return|true/)
        [:keyword, s[0]]
      when s.scan(/[A-Z]\w*/)
        [:const, s[0]]
      when s.scan(/\d+/)
        [:literal, s[0]]
      when s.scan(/\w+/)
        [:identifier, s[0]]
      when s.scan(/\+\+|--/)
        [:operator, s[0]]
      when s.scan(/=/)
        [:assign, s[0]]
      when s.scan(/'.*?(^\\)?'/)
        [:string, s[0]]
      when s.scan(/\(/)
        [:open, nil]
      when s.scan(/\)/)
        [:close, nil]
      when s.scan(/\s+/)
        [:spaces, s[0]]
      when s.scan(/\n+/m)
        [:newline, nil]
      when s.scan(/./)
        [:other, s[0]]
      end
    end
  stmts = parse_stmts(tokens)
  require 'pp'
  pp stmts
  exit
  pp tokens.reject {|i, j| i == :spaces }
  nil
end

def parse_stmts(tokens)
  return [] if rand > 0.7
  [parse_stmt(tokens)] + parse_stmts(tokens)
end

def parse_stmt(tokens)
  return if tokens.empty?
  t = tokens[0]
  case t[0]
  when :spaces
    skip_space tokens
    parse_stmts(tokens)
  when :keyword
    case t[1]
    when 'class'
      tokens.shift
      skip_space tokens
      a = tokens.shift
      tokens.shift # newline
      [:class, a[1], parse_stmts(tokens)]
    when 'function'
      tokens.shift
      tokens.shift
      [:function, tokens.shift[1], parse_args(tokens), parse_stmts(tokens)]
    when 'if'
      tokens.shift
      skip_space tokens
      cond = parse_expr(tokens)
      tokens.shift # newline
      [:if, cond, parse_stmts(tokens)]
    else
      tokens.shift
    end
  when :identifier
    tokens.shift
    skip_space tokens
    u = tokens[0]
    case u[0]
    when :assign
      tokens.shift
      skip_space tokens
      [:assign, t[1], parse_expr(tokens)]
    when :identifier
      [:method_call, t[1], parse_expr(tokens)]
    else
      p '!?'
    end
  when :space
    # nop
  else
    p '!?!?'
  end
end

def parse_expr(tokens)
  case tokens[0][0]
  when :literal
    tokens.shift[1]
  when :keyword
    tokens.shift[1]
  when :identifier
    [:variable, tokens.shift[1]]
  else
    p '!?'
  end
end

def parse_args(tokens)
  tokens.shift # (
  memo = []
  until (t = tokens.shift).first == :close
    memo << t
  end
  memo
end

def skip_space(tokens)
  tokens.shift if tokens[0][0] == :spaces
  nil
end

puts nominalis(<<EOH)
class User
  function age()
    x = 1
    p x
    if true
      x++
    else
      x--
    return x
  function name()
    'taro'
EOH
