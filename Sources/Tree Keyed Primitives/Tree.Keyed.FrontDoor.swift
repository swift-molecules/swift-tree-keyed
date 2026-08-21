public import Hash_Primitives
public import Tree_Primitives

extension __Tree where S: ~Copyable, S: __TreeStorage {

    public typealias Keyed<Key: Hash.`Protocol`> = __Tree<TreeStorage.Keyed<S.Element, Key>>
}
