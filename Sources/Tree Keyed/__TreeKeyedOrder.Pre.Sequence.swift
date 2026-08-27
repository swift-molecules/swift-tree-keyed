public import Iterable
public import Iterator_Chunk
public import Iterator_Primitive
public import Sequence
public import Tree

extension __TreeKeyedOrder.Pre {

    @frozen
    public struct Sequence<S: __TreeKeyedStorage> {
        @usableFromInline
        let tree: __Tree<S>

        @usableFromInline
        init(tree: __Tree<S>) { self.tree = tree }
    }
}

extension __TreeKeyedOrder.Pre.Sequence: Iterable where S.Element: Copyable {

    @_implements(Iterable,Iterator)
    public typealias IterableIterator =
        Iterator_Primitive.Iterator.Materializing<__TreeKeyedOrder.Pre.Iterator<S>>

    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<__TreeKeyedOrder.Pre.Iterator<S>>
    {
        Iterator_Primitive.Iterator.Materializing(__TreeKeyedOrder.Pre.Iterator<S>(tree: tree))
    }
}

extension __TreeKeyedOrder.Pre.Sequence: Sequenceable where S.Element: Copyable {

    @_implements(Sequenceable,Iterator)
    public typealias SequenceableIterator = __TreeKeyedOrder.Pre.Iterator<S>

    public consuming func makeIterator() -> __TreeKeyedOrder.Pre.Iterator<S> {
        __TreeKeyedOrder.Pre.Iterator<S>(tree: tree)
    }
}
