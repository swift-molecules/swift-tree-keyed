public import Buffer_Ring_Primitive
public import Column
internal import Iterator_Primitive
internal import Iterator
public import Ownership_Shared_Primitive
public import Queue
public import Storage_Generational
public import Store_Primitive
public import Tree

extension __TreeKeyedOrder.Level {

    public struct Iterator<S: __TreeKeyedStorage>: Iterator_Primitive.Iterator.`Protocol`
    where S.Element: Copyable {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        var pending:
            __Queue<
                Ownership.Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>
            >

        @usableFromInline
        init(tree: __Tree<S>) {
            self.tree = tree
            self.pending = __Queue<
                Ownership.Shared<Store.Generational.Handle, Column.Ring<Store.Generational.Handle>>
            >()

            if let rootHandle = tree._rootHandle {
                pending.enqueue(rootHandle)
            }
        }

        @inlinable
        public mutating func next() -> S.Element? {
            guard let handle = pending.dequeue() else { return nil }

            let value = tree._value(of: handle)

            for (_, child) in tree._children(of: handle) {
                pending.enqueue(child)
            }

            return value
        }
    }
}
