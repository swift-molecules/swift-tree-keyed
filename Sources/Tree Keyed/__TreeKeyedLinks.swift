public import Column
public import Dictionary_Ordered_Primitive
public import Dictionary_Primitive
public import Hash_Indexed_Primitive
public import Ownership_Shared_Primitive
public import Storage_Generational
public import Store_Primitive

@usableFromInline
struct __TreeKeyedLinks<Key: Hash.`Protocol`> {

    @usableFromInline
    typealias Children = __DictionaryOrdered<
        Ownership.Shared<
            Hash.Entry<Key, Store.Generational.Handle>,
            Hash.Indexed<Column.Heap<Hash.Entry<Key, Store.Generational.Handle>>>
        >
    >

    @usableFromInline var children: Children

    @usableFromInline var parentKey: Key?

    @inlinable
    package init() {
        self.children = Children()
        self.parentKey = nil
    }
}

extension __TreeKeyedLinks: Sendable where Key: Sendable {}
