public import Stack_Primitive
public import Storage_Generational
public import Store_Primitive

@inlinable
public func zip<Key: Swift.Hashable, A: Copyable, B: Copyable>(
    _ lhs: Tree<A>.Keyed<Key>,
    _ rhs: Tree<B>.Keyed<Key>
) -> Tree<(A, B)>.Keyed<Key> {
    var result = Tree<(A, B)>.Keyed<Key>()

    guard let lhsRoot = lhs._rootHandle, let rhsRoot = rhs._rootHandle else {
        return result
    }

    let rootDest = result._insertNode(
        (lhs._value(of: lhsRoot), rhs._value(of: rhsRoot)),
        parent: nil
    )
    result._rootHandle = rootDest

    var pending = Stack<
        (
            lhsHandle: Store.Generational.Handle,
            rhsHandle: Store.Generational.Handle,
            destParent: Store.Generational.Handle
        )
    >()
    pending.push((lhsRoot, rhsRoot, rootDest))

    while let (lhsHandle, rhsHandle, destParentHandle) = pending.pop() {

        for (key, lhsChild) in lhs._children(of: lhsHandle) {
            guard let rhsChild = rhs._childHandle(of: rhsHandle, key: key) else { continue }

            let childDest = result._insertNode(
                (lhs._value(of: lhsChild), rhs._value(of: rhsChild)),
                parent: destParentHandle
            )
            result._linkChild(childDest, to: destParentHandle, at: key)

            pending.push((lhsChild, rhsChild, childDest))
        }
    }

    return result
}
