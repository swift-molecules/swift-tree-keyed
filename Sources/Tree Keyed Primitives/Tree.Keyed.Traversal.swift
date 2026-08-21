public import Tree_Primitives

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    public var preOrder: __TreeKeyedOrder.Pre.Sequence<S> {
        __TreeKeyedOrder.Pre.Sequence<S>(tree: self)
    }

    public var postOrder: __TreeKeyedOrder.Post.Sequence<S> {
        __TreeKeyedOrder.Post.Sequence<S>(tree: self)
    }

    public var levelOrder: __TreeKeyedOrder.Level.Sequence<S> {
        __TreeKeyedOrder.Level.Sequence<S>(tree: self)
    }
}
