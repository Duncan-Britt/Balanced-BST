require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/balanced_bst'

class Tree_Test < MiniTest::Test
  def test_comparable
    a = Tree::Node.new(5)
    b = Tree::Node.new(6)
    c = Tree::Node.new(5)

    assert(a == c)
    refute(a == b)
    refute(a > b)
    assert(a < b)
    assert(a != b)
    refute(a != c)
    assert(a <= b)
    assert(a <= c)
    assert(b > c)
  end
end
