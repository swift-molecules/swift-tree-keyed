public import Stack
public import Storage
public import Store

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func subtree(at keyPath: some Swift.Sequence<Key>) -> __Tree<TreeStorage.Keyed<Value, Key>>? {
        guard let pos = position(at: keyPath) else { return nil }
        guard let sourceHandle = _liveHandle(pos) else { return nil }

        var result = __Tree<TreeStorage.Keyed<Value, Key>>()

        let rootDest = result._insertNode(_value(of: sourceHandle), parent: nil)
        result._rootHandle = rootDest

        var pending = Stack<(source: Store.Generational.Handle, dest: Store.Generational.Handle)>()
        pending.push((sourceHandle, rootDest))

        while let (srcHandle, dstHandle) = pending.pop() {
            for (childKey, childHandle) in _children(of: srcHandle) {
                let newChild = result._insertNode(_value(of: childHandle), parent: dstHandle)
                result._linkChild(newChild, to: dstHandle, at: childKey)
                pending.push((childHandle, newChild))
            }
        }

        return result
    }
}
