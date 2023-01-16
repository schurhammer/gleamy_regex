import rx
import parser
import gleam/io
import gleam/bool
import gleam/bit_string

fn do_example(r: rx.RX, input: String, expected: Bool) {
  let result = rx.match(r, bit_string.from_string(input))
  io.print(input <> "\t")
  io.print(bool.to_string(result) <> "\t")
  io.print(bool.to_string(expected) <> "\n")
}

pub fn main() {
  let rs = "a|(ab)*"
  let r = parser.parse(rs)
  io.println("regex: " <> rs)
  io.println("input\tresult\texpected")
  do_example(r, "a", True)
  do_example(r, "ab", True)
  do_example(r, "abab", True)
  do_example(r, "b", False)
  do_example(r, "aba", False)
}
