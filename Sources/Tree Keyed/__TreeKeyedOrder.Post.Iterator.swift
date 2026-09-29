public import Iterator
public import Stack
public import Storage
public import Store
public import Tree

extension __TreeKeyedOrder.Post {

    public struct Iterator<S: __TreeKeyedStorage>: ~Copyable, Iterator::Iterator.`Protocol`
    where S.Element: Copyable {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        var output: Stack<Store.Generational.Handle>

        @usableFromInline
        init(tree: __Tree<S>) {
            self.tree = tree
            self.output = Stack<Store.Generational.Handle>()

            var pending = Stack<Store.Generational.Handle>()
            if let rootHandle = tree._rootHandle {
                pending.push(rootHandle)
            }

            while let handle = pending.pop() {
                output.push(handle)

                for (_, child) in tree._children(of: handle) {
                    pending.push(child)
                }
            }
        }

        @inlinable
        public mutating func next() -> S.Element? {
            guard let handle = output.pop() else { return nil }
            return tree._value(of: handle)
        }
    }
}
