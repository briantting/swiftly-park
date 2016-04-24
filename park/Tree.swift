//
//  Tree.swift
//  park
//
//  Created by Ethan Brooks on 4/11/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation

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
    
    func value() -> T? {
        switch self {
        case let Tree(_, root, _, _): return root
        case .Leaf: return nil
        }
    }
    
    func getLeft() -> Node<T>? {
        switch self {
        case let Tree(l, _, _, _): return l
        case .Leaf: return nil
        }
    }
    
    func getRight() -> Node<T>? {
        switch self {
        case let Tree(_, _, r, _): return r
        case .Leaf: return nil
        }
    }
    
    func height() -> Int {
        switch self {
        case Tree(_, _, _, let height): return height
        case Leaf: return 0
        }
    }
    
    func getHeight(left: Node<T>, _ right: Node<T>) -> Int {
        return max(left.height(), right.height()) + 1
    }
    
    func apply<U>(f: Node<T> -> U,
               onLeftBranchIf condition: Bool) -> U? {
        if case let Tree(left, _, right, _) = self {
            return condition ? f(left) : f(right)
        }
        return nil
    }
    
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
    
    func insert(value: T) -> Node<T> {
        switch self {
        case let Tree(_, root, _, _):
            return self
                .substitute({$0.insert(value)},
                            forLeftBranchIf: value < root)!
                .rotate()
            
        case Leaf:
            return Tree(Node.Leaf, value, Node.Leaf, 1)
        }
    }
    
    
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
    
    func rotate() -> Node<T> {
        switch self {
        case Leaf: return Leaf
        case let Tree(leftBranch, _, rightBranch, _):
            switch leftBranch.height() - rightBranch.height() {
            case -1...1:
                return self
            default:
                let leftIsHigher = leftBranch.height() > rightBranch.height()
                let branch = leftIsHigher ? leftBranch : rightBranch
                switch branch {
                case Leaf: return self
                case let Tree:
                    
                    func graft(middleBranch: Node<T>) -> Node<T> {
                        return self.substitute({_ in middleBranch},
                                               forLeftBranchIf: leftIsHigher)!
                    }
                    
                    return branch.substitute({graft($0)},
                                             forLeftBranchIf: !leftIsHigher)!
                }
            }
        }
    }
    
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
    
    func balanced() -> Bool {
        switch self {
        case Leaf: return true
        case let Tree(leftBranch, _, rightBranch, _):
            return abs(leftBranch.height() - rightBranch.height()) < 2
                && leftBranch.balanced() && rightBranch.balanced()
        }
    }
}