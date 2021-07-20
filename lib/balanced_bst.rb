# frozen_string_literal: false

# rubocop:disable Metrics/ClassLength
module BalancedBST
  # Balanced Binary Search Tree
  class Tree
    attr_accessor :root

    # rubocop:disable Metrics/AbcSize
    def balanced?
      return true if root.leaf?
      return root.child.leaf? if root.one_child?

      left_height = height(root.left.data)
      right_height = height(root.right.data)
      difference = (left_height - right_height).abs
      difference <= 1
    end
    # rubocop:enable Metrics/AbcSize

    def rebalance
      Tree.new(level_order)
    end

    def rebalance!
      return self if balanced?

      build_tree(level_order)
      self
    end

    def initialize(collection)
      if collection.empty?
        raise(
          EmptyCollectionError,
          'Array must contain at least one element'
        )
      end

      build_tree(collection)
    end

    def delete(data)
      node = Node.new(data)
      return root.delete(node) unless node == root

      replacement = root.inorder_successor
      root.detach_inorder_successor
      replacement.left = root.left
      replacement.right = root.right
      self.root = replacement
    end

    def depth(data)
      to_find = Node.new(data)
      node = root
      [up_edges(node.left, to_find), up_edges(node.right, to_find)].max
    end

    def find(data)
      to_find = Node.new(data)

      each_level_order { |node| return node if node == to_find }
    end

    def height(data)
      node = find(data)
      [edges(node.left), edges(node.right)].max
    end

    def inorder(node = root)
      collection = []
      collection += inorder(node.left) if node.left
      collection << node.data
      collection += inorder(node.right) if node.right
      collection
    end

    def insert(data)
      node = Node.new(data)
      root.insert(node)
    end

    def level_order
      collection = []
      each_level_order { |node| collection << node.data }
      collection
    end

    def each_level_order
      queue = [root]
      until queue.empty?
        node = queue.shift
        yield(node) if block_given?
        if node.one_child?
          queue << node.child
        elsif !node.leaf?
          node.children.each { |e| queue << e }
        end
      end
    end

    def postorder(node = root)
      collection = []
      collection += postorder(node.left) if node.left
      collection += postorder(node.right) if node.right
      collection << node.data
      collection
    end

    def preorder(node = root)
      collection = []
      collection << node.data
      collection += preorder(node.left) if node.left
      collection += preorder(node.right) if node.right
      collection
    end

    def pretty_print(node = root, prefix = '', is_left = true)
      pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
      puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
      pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
    end

    private

    # rubocop:disable Metrics/AbcSize
    def build_tree(collection)
      collection = collection.sort.uniq
      return self.root = Node.new(collection[0]) if collection.size == 1

      mid_idx = collection.size / 2
      left_half = collection[0...mid_idx]
      right_half = collection[mid_idx + 1..collection.size - 1]

      self.root = Node.new(collection[mid_idx])
      root.left = subtree(left_half)
      root.right = subtree(right_half)
    end

    def subtree(collection)
      return Node.new(collection[0]) if collection.size == 1

      mid_idx = collection.size / 2
      left_half = (collection[0...mid_idx] || [])
      right_half = (collection[mid_idx + 1..collection.size - 1] || [])

      node = Node.new(collection[mid_idx])
      node.left = subtree(left_half) unless left_half.empty?
      node.right = subtree(right_half) unless right_half.empty?
      node
    end
    # rubocop:enable Metrics/AbcSize

    def edges(node)
      return 0 unless node
      return 1 if node.leaf?

      [edges(node.left), edges(node.right)].max + 1
    end

    def up_edges(node, to_find, depth = 0)
      return 0 unless node

      depth += 1
      return depth if node == to_find

      [up_edges(node.left, to_find, depth), up_edges(node.right, to_find, depth)].max
    end
  end

  # Tree Node
  class Node
    include Comparable

    attr_reader :data
    attr_accessor :left, :right

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def delete(node)
      case node <=> self
      when -1
        if left == node
          setter = ->(nde) { self.left = nde }
          branch = -> { left }
          eliminate(setter, branch)
        else
          left.delete(node)
        end
      when 1
        if right == node
          setter = ->(nde) { self.right = nde }
          branch = -> { right }
          eliminate(setter, branch)
        else
          right.delete(node)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def eliminate(branch_assignment, branch)
      return branch_assignment.call(nil) if branch.call.leaf?
      return branch_assignment.call(branch.call.child) if branch.call.one_child?

      replacement = branch.call.inorder_successor
      branch.call.detach_inorder_successor
      replacement.left = branch.call.left
      replacement.right = right.right
      branch_assignment.call(replacement)
    end

    def initialize(data)
      @data = data
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Style/RedundantReturn
    # rubocop:disable Metrics/MethodLength
    def insert(node)
      case node <=> self
      when -1
        if left
          left.insert(node)
        else
          self.left = node
        end
      when 0
        return
      when 1
        if right
          right.insert(node)
        else
          self.right = node
        end
      end
    end
    # rubocop:enable Style/RedundantReturn
    # rubocop:enable Metrics/MethodLength

    def <=>(other)
      data <=> other.data
    end

    def inorder_successor
      node = right
      node = node.left while node.left
      node
    end

    def child
      left || right
    end

    def children
      return if leaf?
      return child if one_child?

      [left, right]
    end

    def leaf?
      !left && !right
    end

    def one_child?
      !!left ^ !!right
    end

    def detach_inorder_successor
      node = right
      unless node.left
        self.right = nil
        return
      end
      node = node.left while node.left.left
      node.left = nil
    end
  end

  class EmptyCollectionError < StandardError; end
end
# rubocop:enable Metrics/ClassLength

tree = BalancedBST::Tree.new(('A'..'K').to_a)
tree.pretty_print
