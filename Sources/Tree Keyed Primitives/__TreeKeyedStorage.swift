public import Hash_Primitives
public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

public protocol __TreeKeyedStorage: __TreeStorage
where Address: Hash.`Protocol`, Error == __TreeKeyedError<Address> {

    func _parentKey(of handle: Store.Generational.Handle) -> Address?

    func _children(
        of handle: Store.Generational.Handle
    ) -> [(key: Address, handle: Store.Generational.Handle)]
}
