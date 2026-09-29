public import Memory
public import Memory_Allocator
public import Storage
public import Buffer
public import Buffer_Linear_Primitive
public import Store

public import Dictionary_Ordered_Primitive
public import Dictionary
public import Hash_Indexed_Primitive
public import Ownership_Shared_Primitive

@usableFromInline
struct __TreeKeyedLinks<Key: Swift.Hashable> {

    @usableFromInline
    typealias Children = __DictionaryOrdered<
        Ownership.Shared<
            Hash.Entry<Key, Store.Generational.Handle>,
            Hash.Indexed<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Hash.Entry<Key, Store.Generational.Handle>>>.Linear>
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
