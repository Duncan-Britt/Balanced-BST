# Balanced Binary Search Tree
class Tree
  # Tree nodes
  class Node
    include Comparable

    attr_reader :data
    attr_accessor :left, :right

    def delete(node)
      case node <=> self
      when -1
        if left == node
          return self.left = nil if left.leaf?
          return self.left = left.child if left.one_child?
          replacement = left.inorder_successor
          left.detach_inorder_successor
          replacement.left = left.left
          replacement.right = left.right
          self.left = replacement
        else
          left.delete(node)
        end
      when 1
        if right == node
          return self.right = nil if right.leaf?
          return self.right = right.child if right.one_child?
          replacement = right.inorder_successor
          right.detach_inorder_successor
          replacement.left = right.left
          replacement.right = right.right
          self.right = replacement
        else
          right.delete(node)
        end
      end
    end

    def initialize(data)
      @data = data
    end

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

    def inspect
      # return "(#{data})" if leaf?
      # if one_child?
      #   return "(#{left.data}<=#{data})" if left
      #   return "(#{data}=>#{right.data})"
      # end
      # "(#{left.data}<=#{data}=>#{right.data})"
      data
    end

    def <=>(other)
      data <=> other.data
    end

    def inorder_successor
      node = right
      while node.left
        node = node.left
      end
      node
    end

    def child
      left || right
    end

    def children
      return if leaf?
      return child if one_child?
      return left, right
    end

    def leaf?
      !left && !right
    end

    def one_child?
      !!left ^ !!right
    end

    def detach_inorder_successor
      node = self.right
      unless node.left
        self.right = nil
        return
      end
      while node.left.left
        node = node.left
      end
      node.left = nil
    end
  end

  class EmptyCollectionError < StandardError; end

  attr_accessor :root

  def initialize(collection)
    if collection.empty?
      raise EmptyCollectionError.new("Array must contain at least one element")
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

  def find(data)
    to_find = Node.new(data)
    node = root
    queue = node.children
    until node == to_find || queue.empty?
      child = queue.shift
      if child.one_child?
        queue << child.child
      elsif !child.leaf?
        child.children.each { |e| queue << e }
      end
      node = child
    end
    return nil unless node == to_find
    node
  end

  def height(data)
    node = find(data)
    [edges(node.left), edges(node.right)].max
  end

  def edges(node)
    return 0 unless node
    return 1 if node.leaf?
    [edges(node.left), edges(node.right)].max + 1
  end

  def depth(data)
    to_find = Node.new(data)
    node = root
    [up_edges(node.left, to_find), up_edges(node.right, to_find)].max
  end

  def up_edges(node, to_find, depth=0)
    return 0 unless node
    depth += 1
    return depth if node == to_find
    [up_edges(node.left, to_find, depth), up_edges(node.right, to_find, depth)].max
  end

  def inorder(node=root)
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
    node = root
    collection = [node.data]
    queue = node.children
    until queue.empty?
      child = queue.shift
      collection << child.data
      if child.one_child?
        queue << child.child
      elsif !child.leaf?
        child.children.each { |e| queue << e }
      end
      node = child
    end
    collection
  end

  def postorder(node=root)
    collection = []
    collection += postorder(node.left) if node.left
    collection += postorder(node.right) if node.right
    collection << node.data
    collection
  end

  def preorder(node=root)
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

  def build_tree(collection)
    collection = collection.sort.uniq
    if collection.size == 1
      self.root = Node.new(collection[0])
      return
    end
    mid_idx = collection.size / 2
    left_half = collection[0...mid_idx]
    right_half = collection[mid_idx+1..collection.size-1]

    self.root = Node.new(collection[mid_idx])
    root.left = subtree(left_half)
    root.right = subtree(right_half)
  end

  def subtree(collection)
    return Node.new(collection[0]) if collection.size == 1

    mid_idx = collection.size / 2
    left_half = (collection[0...mid_idx] || [])
    right_half = (collection[mid_idx+1..collection.size-1] || [])

    node = Node.new(collection[mid_idx])
    node.left = subtree(left_half) unless left_half.empty?
    node.right = subtree(right_half) unless right_half.empty?
    node
  end
end

bst = Tree.new(('A'..'K').to_a)
bst.insert('L')
bst.insert('M')
bst.pretty_print
