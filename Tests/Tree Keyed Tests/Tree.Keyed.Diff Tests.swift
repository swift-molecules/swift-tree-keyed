import Testing
import Index_Test_Support

@testable import Tree_Keyed

private typealias KeyedInsertPosition = __Tree<TreeStorage.Keyed<Int, String>>.Insert.Position

@Suite
struct `Tree.Keyed.Diff Tests` {
    @Suite struct Unit {}
    @Suite struct Integration {}
}

private func makeThreeLevelTree() throws -> __Tree<TreeStorage.Keyed<Int, String>> {
    var tree = __Tree<TreeStorage.Keyed<Int, String>>()
    let root = try tree.insert(0, at: KeyedInsertPosition.root)
    let a = try tree.insert(1, at: .child(of: root, key: "a"))
    _ = try tree.insert(10, at: .child(of: a, key: "x"))
    _ = try tree.insert(20, at: .child(of: a, key: "y"))
    let b = try tree.insert(2, at: .child(of: root, key: "b"))
    _ = try tree.insert(30, at: .child(of: b, key: "z"))
    return tree
}

extension `Tree.Keyed.Diff Tests`.Unit {

    @Test func `diff of two empty trees is empty`() {
        let old = __Tree<TreeStorage.Keyed<Int, String>>()
        let new = __Tree<TreeStorage.Keyed<Int, String>>()
        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.isEmpty)
        #expect(diff.operations.isEmpty)
    }

    @Test func `diff of identical single-node trees is empty`() {
        let old = __Tree<TreeStorage.Keyed<Int, String>>(rootValue: 42)
        let new = __Tree<TreeStorage.Keyed<Int, String>>(rootValue: 42)
        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.isEmpty)
    }

    @Test func `diff detects modified root value`() {
        let old = __Tree<TreeStorage.Keyed<Int, String>>(rootValue: 1)
        let new = __Tree<TreeStorage.Keyed<Int, String>>(rootValue: 2)
        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)

        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .modified(path: [], old: 1, new: 2))
    }

    @Test func `diff detects added child`() throws {
        var old = __Tree<TreeStorage.Keyed<Int, String>>()
        _ = try old.insert(0, at: KeyedInsertPosition.root)

        var new = __Tree<TreeStorage.Keyed<Int, String>>()
        let newRoot = try new.insert(0, at: KeyedInsertPosition.root)
        _ = try new.insert(1, at: .child(of: newRoot, key: "a"))

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .added(path: ["a"], value: 1))
    }

    @Test func `diff detects removed child`() throws {
        var old = __Tree<TreeStorage.Keyed<Int, String>>()
        let oldRoot = try old.insert(0, at: KeyedInsertPosition.root)
        _ = try old.insert(1, at: .child(of: oldRoot, key: "a"))

        var new = __Tree<TreeStorage.Keyed<Int, String>>()
        _ = try new.insert(0, at: KeyedInsertPosition.root)

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .removed(path: ["a"], value: 1))
    }

    @Test func `diff detects modified child value`() throws {
        var old = __Tree<TreeStorage.Keyed<Int, String>>()
        let oldRoot = try old.insert(0, at: KeyedInsertPosition.root)
        _ = try old.insert(1, at: .child(of: oldRoot, key: "a"))

        var new = __Tree<TreeStorage.Keyed<Int, String>>()
        let newRoot = try new.insert(0, at: KeyedInsertPosition.root)
        _ = try new.insert(99, at: .child(of: newRoot, key: "a"))

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .modified(path: ["a"], old: 1, new: 99))
    }

    @Test func `diff of nil vs populated produces all added`() throws {
        let old = __Tree<TreeStorage.Keyed<Int, String>>()
        var new = __Tree<TreeStorage.Keyed<Int, String>>()
        let root = try new.insert(0, at: KeyedInsertPosition.root)
        _ = try new.insert(1, at: .child(of: root, key: "a"))

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        let addedValues = diff.operations.compactMap { op -> Int? in
            if case .added(_, let v) = op { return v }
            return nil
        }
        #expect(addedValues.count == 2)
        #expect(addedValues.contains(0))
        #expect(addedValues.contains(1))
    }

    @Test func `diff of populated vs nil produces all removed`() throws {
        var old = __Tree<TreeStorage.Keyed<Int, String>>()
        let root = try old.insert(0, at: KeyedInsertPosition.root)
        _ = try old.insert(1, at: .child(of: root, key: "a"))
        let new = __Tree<TreeStorage.Keyed<Int, String>>()

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        let removedValues = diff.operations.compactMap { op -> Int? in
            if case .removed(_, let v) = op { return v }
            return nil
        }
        #expect(removedValues.count == 2)
        #expect(removedValues.contains(0))
        #expect(removedValues.contains(1))
    }
}

extension `Tree.Keyed.Diff Tests`.Integration {

    @Test func `diff detects nested changes at depth`() throws {
        let old = try makeThreeLevelTree()
        var new = try makeThreeLevelTree()
        try new.update(99, at: ["a", "x"])

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .modified(path: ["a", "x"], old: 10, new: 99))
    }

    @Test func `diff reports full subtree as added`() throws {
        let old = try makeThreeLevelTree()
        var new = try makeThreeLevelTree()
        let bPos = new.position(at: ["b"])!
        _ = try new.insert(40, at: .child(of: bPos, key: "w"))

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        #expect(diff.operations.count == 1)
        #expect(diff.operations[0] == .added(path: ["b", "w"], value: 40))
    }

    @Test func `diff reports full subtree as removed`() throws {
        var old = try makeThreeLevelTree()
        let bPos = old.position(at: ["b"])!
        let w = try old.insert(40, at: .child(of: bPos, key: "w"))
        _ = try old.insert(41, at: .child(of: w, key: "w1"))

        let new = try makeThreeLevelTree()

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)
        let removedPaths = diff.operations.compactMap { op -> [String]? in
            if case .removed(let path, _) = op { return path }
            return nil
        }
        #expect(removedPaths.count == 2)
        #expect(removedPaths.contains(["b", "w"]))
        #expect(removedPaths.contains(["b", "w", "w1"]))
    }

    @Test func `diff handles mixed operations`() throws {
        let old = try makeThreeLevelTree()
        var new = try makeThreeLevelTree()

        try new.update(99, at: ["a", "y"])

        let bPos = new.position(at: ["b"])!
        let zPos = new.child.at("z", of: bPos)!
        _ = try new.remove(at: zPos)

        _ = try new.insert(50, at: .child(of: bPos, key: "q"))

        let diff = __Tree<TreeStorage.Keyed<Int, String>>.diff(from: old, to: new)

        let modified = diff.operations.filter {
            if case .modified = $0 { return true }
            return false
        }
        let added = diff.operations.filter {
            if case .added = $0 { return true }
            return false
        }
        let removed = diff.operations.filter {
            if case .removed = $0 { return true }
            return false
        }

        #expect(modified.count == 1)
        #expect(added.count == 1)
        #expect(removed.count == 1)
    }
}
