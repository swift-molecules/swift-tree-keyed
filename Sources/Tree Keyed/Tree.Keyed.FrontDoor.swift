public import Tree

extension __Tree where S: ~Copyable, S: __TreeStorage {

    public typealias Keyed<Key: Swift.Hashable> = __Tree<TreeStorage.Keyed<S.Element, Key>>
}
