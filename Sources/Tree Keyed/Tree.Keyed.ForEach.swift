public import Stack_Primitive
public import Storage_Generational
public import Store_Primitive

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func forEach<E>(
        _ body: ([Key], Value) throws(E) -> Void
    ) throws(E) {
        guard let rootHandle = _rootHandle else { return }

        var pending = Stack<(handle: Store.Generational.Handle, path: [Key])>()
        pending.push((rootHandle, []))

        while let (handle, path) = pending.pop() {
            try body(path, _value(of: handle))

            let children = _children(of: handle)
            for i in (0..<children.count).reversed() {
                var childPath = path
                childPath.append(children[i].key)
                pending.push((children[i].handle, childPath))
            }
        }
    }

    @inlinable
    public func forEach<E>(
        _ body: ([Key], Value) async throws(E) -> Void
    ) async throws(E) {
        guard let rootHandle = _rootHandle else { return }

        var pending = Stack<(handle: Store.Generational.Handle, path: [Key])>()
        pending.push((rootHandle, []))

        while let (handle, path) = pending.pop() {
            try await body(path, _value(of: handle))

            let children = _children(of: handle)
            for i in (0..<children.count).reversed() {
                var childPath = path
                childPath.append(children[i].key)
                pending.push((children[i].handle, childPath))
            }
        }
    }
}
