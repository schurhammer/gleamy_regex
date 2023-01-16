import rx.{RX}
import gleam/bit_string as bs

pub fn parse(input: String) -> RX {
  let #(_, rx) = regex(bs.from_string(input))
  rx
}

fn regex(input: BitString) -> #(BitString, RX) {
  assert #(input, term) = term(input)
  assert <<pipe>> = bs.from_string("|")
  case input {
    <<a, rest:bit_string>> if a == pipe -> {
      let #(rest, rx) = regex(rest)
      #(rest, rx.Or(term, rx))
    }
    _ -> #(input, term)
  }
}

fn term(input: BitString) -> #(BitString, RX) {
  term_loop(input)
}

fn term_loop(input) {
  assert <<cb, pipe>> = bs.from_string(")|")
  case input {
    <<a, _:bit_string>> if a != cb && a != pipe -> {
      let #(rest, fact) = factor(input)
      let #(rest, term) = term_loop(rest)
      case term {
        rx.EmptyString -> #(rest, fact)
        _ -> #(rest, rx.Chain(fact, term))
      }
    }
    _ -> #(input, rx.EmptyString)
  }
}

fn factor(input: BitString) -> #(BitString, RX) {
  let #(input, ba) = base(input)
  factor_loop(input, ba)
}

fn factor_loop(input, acc) {
  assert <<star>> = bs.from_string("*")
  case input {
    <<a, rest:bit_string>> if a == star -> {
      let acc = rx.Repeat(acc)
      factor_loop(rest, acc)
    }
    _ -> #(input, acc)
  }
}

fn base(input: BitString) -> #(BitString, RX) {
  assert <<open, close, back>> = bs.from_string("()\\")
  case input {
    <<a, rest:bit_string>> if a == open -> {
      assert #(<<_b, rest:bit_string>>, rx) = regex(rest)
      assert _b = close
      #(rest, rx)
    }
    <<a, b, rest:bit_string>> if a == back -> #(rest, rx.Char(b))
    <<a, rest:bit_string>> -> #(rest, rx.Char(a))
  }
}
