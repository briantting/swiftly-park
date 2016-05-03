//
//  Tree.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

indirect enum Node<T where T:Comparable, T:Hashable> : CustomStringConvertible {
    case Leaf
    case Tree(Node<T>, T, Node<T>, Int)
    
    var description: String {
        switch self {
        case .Leaf:
            return "_"
        case let Tree(left, v, right, h):
            return "(\(left) \(v)[\(h)] \(right))"
        }
    }
    
    /**
     - returns:
     value of root node
     */
    func value() -> T? {
        switch self {
        case let Tree(_, root, _, _): return root
        case .Leaf: return nil
        }
    }
    
    /**
     - returns:
     root of left branch
     */
    func getLeft() -> Node<T>? {
        switch self {
        case let Tree(l, _, _, _): return l
        case .Leaf: return nil
        }
    }
    
    /**
     - returns:
     return root of right branch
     */
    func getRight() -> Node<T>? {
        switch self {
        case let Tree(_, _, r, _): return r
        case .Leaf: return nil
        }
    }
    
    /**
     - returns:
     height of tree
     */
    func height() -> Int {
        switch self {
        case Tree(_, _, _, let height): return height
        case Leaf: return 0
        }
    }
    
    /**
     - param left:
     left branch
     
     - param right:
     right branch
     
     - returns:
     height of tree based on heights of left and right branches
     */
    func getHeight(left: Node<T>, _ right: Node<T>) -> Int {
        return max(left.height(), right.height()) + 1
    }
    
    /**
     - param f:
     function to be applied
     
     - param onLeftBranchIf:
     applies f to left branch if this condition is met
     
     - returns:
     result of application of f
     */
    func apply<U>(f: Node<T> -> U,
               onLeftBranchIf condition: Bool) -> U? {
        if case let Tree(left, _, right, _) = self {
            return condition ? f(left) : f(right)
        }
        return nil
    }
    
    /**
     - param f:
     function to be applied
     
     - param onLeftBranchIf:
     applies f to left branch if this condition is met
     
     - returns:
     result self with result of function application substituted for
     the branch to which it was applied
     */
    func substitute(f: Node<T> -> Node<T>,
                    forLeftBranchIf condition: Bool) -> Node<T>? {
        if case let Tree(left, root, right, _) = self {
            var (left, right) = (left, right)
            if condition {
                left = f(left)
            } else {
                right = f(right)
            }
            return Tree(left, root, right, getHeight(left, right))
        }
        return nil
    }
    
    /**
     - param value:
     value to insert
     
     - returns:
     self with value inserted
     */
    func insert(value: T) -> Node<T> {
        switch self {
        case let Tree(_, root, _, _):
            if value == root {
                return self
            }
            return self
                .substitute({$0.insert(value)},
                            forLeftBranchIf: value < root)!
                .rotate()
            
        case Leaf:
            return Tree(Node.Leaf, value, Node.Leaf, 1)
        }
    }
    
    /**
     - param left:
     see returns
     
     - returns:
     far left value of self (if left is true, otherwise far right value)
     */
    func far(left left: Bool, prev: Node<T>? = nil) -> T? {
        switch self {
        case Tree:
            return apply({$0.far(left: left, prev: self)},
                         onLeftBranchIf: left)!
        case Leaf:
            if prev != nil {
                if case let Tree(_, value, _, _) = prev! {
                    return value
                }
            }
        }
        return nil
    }
    
    /**
     - param left:
     see returns
     
     - returns:
     self with far left value removed
     (if left is true, otherwise far right value)
     */
    func removeFar(left left: Bool) -> (Node<T>)? {
        
        switch self {
        case Leaf: return nil
        case let Tree(leftBranch, _, rightBranch, _):
            
            func recursion(branch: Node<T>) -> Node<T> {
                switch branch {
                case Tree: return self
                    .substitute({$0.removeFar(left: left)!},
                                forLeftBranchIf: left)!
                case Leaf:
                    return left ? rightBranch : leftBranch
                }
            }
            
            return self
                .apply(recursion, onLeftBranchIf: left)!
                .rotate()
        }
    }
    
    /**
     - param value:
     value to remove
     
     - returns:
     self with value removed
     */
    func remove(value: T) -> Node<T> {
        switch self {
        case let Tree(left, root, right, _):
            if value == root {
                switch right {
                case Tree:
                    let newRoot = right.far(left: true)!
                    let newRight = right.removeFar(left: true)!
                    let newHeight = getHeight(left, newRight)
                    return Tree(left, newRoot, newRight, newHeight)
                        .rotate()
                case Leaf: return left
                }
            } else {
                return self.substitute({$0.remove(value)},
                                       forLeftBranchIf: value < root)!
                    .rotate()
            }
        case Leaf:
            return self;
        }
    }
    
    /**
     - returns:
     self but rotated to improve balance between left and right branches.
     Does not recurse down branches
     */
    func rotate() -> Node<T> {
        switch self {
        case Leaf: return Leaf
        case let Tree(leftBranch, _, rightBranch, _):
            switch leftBranch.height() - rightBranch.height() {
            case -1...1: return self
            default:
                let leftIsHigher = leftBranch.height() > rightBranch.height()
                
                func graft(middleBranch: Node<T>) -> Node<T> {
                    return self.substitute({_ in middleBranch},
                                           forLeftBranchIf: leftIsHigher)!
                }
                
                func prune(branch : Node<T>) -> Node<T> {
                    return branch.substitute({graft($0)},
                                             forLeftBranchIf: !leftIsHigher)!
                }
                
                return self.apply(prune, onLeftBranchIf: leftIsHigher)!
            }
        }
    }
    
    /**
     - a:
     returned values are between a and b (inclusive)
     
     - b:
     returned values are between a and b (inclusive)
    
     - condition:
     function that must return true when applied to value for value to
     be included in return set.
     
     - returns:
     all values between a and b (inclusive) that meet condition (if specified)
     */
    func valuesBetween(a: T, and b: T,
                       if condition: T->Bool = {_ in true}) -> Set<T> {
        switch self {
        case .Leaf:
            return Set()
        case let Tree(left, root, right, _):
            switch root {
            case a...b:
                let values = [left, right]
                    .map({$0.valuesBetween(a, and: b, if: condition)})
                let s = condition(root) ? Set([root]) : Set()
                return s.union(values[0])
                    .union(values[1])
            default:
                return self.apply({$0.valuesBetween(a, and: b, if: condition)},
                                  onLeftBranchIf: a < root)!
            }
        }
    }
    
    /**
     - returns:
     true if tree is fully balanced (including subtrees)
     */
    func balanced() -> Bool {
        switch self {
        case Leaf: return true
        case let Tree(leftBranch, _, rightBranch, _):
            return abs(leftBranch.height() - rightBranch.height()) < 2
                && leftBranch.balanced() && rightBranch.balanced()
        }
    }
}