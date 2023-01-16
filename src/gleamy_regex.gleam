import rx
import gleam/io
import gleam/bit_string

pub fn main() {
  assert <<a, b, c>> = bit_string.from_string("abc")

  let r = rx.Repeat(rx.Or(rx.Char(a), rx.Char(b)))
  io.debug(r)

  // prints True, abba is a match
  let u1 = <<a, b, b, a>>
  io.debug(u1)
  io.debug(rx.match(r, u1))

  // prints False, abca is not a match
  let u2 = <<a, b, c, a>>
  io.debug(u2)
  io.debug(rx.match(r, u2))
}
