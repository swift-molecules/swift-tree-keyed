public import Storage_Generational
public import Store_Primitive
public import Tree

public protocol __TreeKeyedStorage: __TreeStorage
where Address: Swift.Hashable, Error == __TreeKeyedError<Address> {

    func _parentKey(of handle: Store.Generational.Handle) -> Address?

    func _children(
        of handle: Store.Generational.Handle
    ) -> [(key: Address, handle: Store.Generational.Handle)]
}
