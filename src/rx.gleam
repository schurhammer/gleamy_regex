// A regex matching engine based on Brzozowski derivatives.
//
// References:
// "Derivatives of Regular Expressions" by Brzozowski
// "Regular-expression derivatives reexamined" by Owens

// TODO CharRage
// TODO cache the result of v() on each node (test performance)
// TODO use intersection and union during derive to keep tree smaller (test performance)
// TODO tests

pub type RX {
  EmptySet
  EmptyString
  Char(c: Int)
  Or(r: RX, s: RX)
  And(r: RX, s: RX)
  Not(r: RX)
  Chain(r: RX, s: RX)
  Repeat(r: RX)
}

pub fn derive(rx: RX, a: Int) -> RX {
  case rx {
    Char(b) if a == b -> EmptyString
    Char(_) -> EmptySet
    EmptyString -> EmptySet
    EmptySet -> EmptySet
    Repeat(r) -> Chain(derive(r, a), rx)
    Chain(r, s) -> Or(Chain(derive(r, a), s), Chain(v(r), derive(s, a)))
    And(r, s) -> And(derive(r, a), derive(s, a))
    Or(r, s) -> Or(derive(r, a), derive(s, a))
    Not(r) -> Not(derive(r, a))
  }
}

fn union(r: RX, s: RX) -> RX {
  case r, s {
    EmptyString, _ -> EmptyString
    _, EmptyString -> EmptyString
    EmptySet, EmptySet -> EmptySet
    r, s -> Or(r, s)
  }
}

fn intersection(r: RX, s: RX) -> RX {
  case r, s {
    EmptySet, _ -> EmptySet
    _, EmptySet -> EmptySet
    EmptyString, EmptyString -> EmptyString
    r, s -> And(r, s)
  }
}

pub fn v(rx: RX) -> RX {
  case rx {
    Char(_) -> EmptySet
    EmptyString -> EmptyString
    EmptySet -> EmptySet
    Repeat(_) -> EmptyString
    Chain(r, s) -> intersection(v(r), v(s))
    And(r, s) -> intersection(v(r), v(s))
    Or(r, s) -> union(v(r), v(s))
    Not(rx) ->
      case v(rx) {
        EmptySet -> EmptyString
        _ -> EmptySet
      }
  }
}

pub fn match(rx: RX, u: BitString) -> Bool {
  case u {
    <<>> ->
      case v(rx) {
        EmptyString -> True
        _ -> False
      }
    <<a:int, w:bit_string>> -> match(derive(rx, a), w)
  }
}
