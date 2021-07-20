# frozen_string_literal: false

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../lib/balanced_bst'

class NodeTest < MiniTest::Test
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def test_comparable
    a = BalancedBST::Node.new(5)
    b = BalancedBST::Node.new(6)
    c = BalancedBST::Node.new(5)

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

class TreeTest < MiniTest::Test
  def setup
    @letters = BalancedBST::Tree.new(('A'..'K').to_a)
  end

  def test_tree_must_have_at_least_one_element
    assert_raises(BalancedBST::EmptyCollectionError) do
      BalancedBST::Tree.new([])
    end
  end

  def test_find
    expected = BalancedBST::Node.new('I')
    actual = @letters.find('I')
    assert_equal expected, actual
    assert_nil @letters.find('T')
  end

  def test_level_order
    expected = %w[F C I B E H K A D G J]
    actual = @letters.level_order
    assert_equal expected, actual
  end

  def test_inorder
    expected = %w[A B C D E F G H I J K]
    actual = @letters.inorder
    assert_equal expected, actual
  end

  def test_preorder
    expected = %w[F C B A E D I H G K J]
    actual = @letters.preorder
    assert_equal expected, actual
  end

  def test_postorder
    expected = %w[A B D E C G H J K I F]
    actual = @letters.postorder
    assert_equal expected, actual
  end

  def test_height
    assert_equal 1, @letters.height('E')
    assert_equal 2, @letters.height('I')
    assert_equal 3, @letters.height('F')
    @letters.insert('L')
    @letters.insert('M')
    assert_equal 4, @letters.height('F')
  end

  def test_depth
    assert_equal 0, @letters.depth('F')
    assert_equal 1, @letters.depth('C')
    assert_equal 2, @letters.depth('H')
    assert_equal 3, @letters.depth('D')
  end

  def test_balanced
    assert(@letters.balanced?)

    @letters.insert('L')
    assert(@letters.balanced?)

    @letters.insert('M')
    assert(@letters.balanced?)

    @letters.insert('N')
    refute(@letters.balanced?)
  end

  def test_rebalance
    @letters.insert('L')
    @letters.insert('M')
    @letters.insert('N')
    @letters.insert('O')
    refute(@letters.balanced?)
    new_tree = @letters.rebalance
    assert(new_tree.balanced?)
    refute_same(new_tree, @letters)
  end

  def test_rebalance!
    @letters.insert('L')
    @letters.insert('M')
    @letters.insert('N')
    @letters.insert('O')
    refute(@letters.balanced?)
    same_tree = @letters.rebalance!
    assert(@letters.balanced?)
    assert_same(@letters, same_tree)
  end

  def test_delete
    @letters.delete('F')
    expected = %w[A B C D E G H I J K]
    assert_equal expected, @letters.inorder

    @letters.delete('I')
    expected = %w[A B C D E G H J K]
    assert_equal expected, @letters.inorder

    @letters.delete('D')
    expected = %w[A B C E G H J K]
    assert_equal expected, @letters.inorder
  end

  # rubocop: disable Layout/HeredocIndentation
  def test_pretty_print
    expected = <<-MSG
│       ┌── K
│       │   └── J
│   ┌── I
│   │   └── H
│   │       └── G
└── F
    │   ┌── E
    │   │   └── D
    └── C
        └── B
            └── A
    MSG

    assert_output(expected) do
      @letters.pretty_print
    end
  end
  # rubocop:enable Layout/HeredocIndentation
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
