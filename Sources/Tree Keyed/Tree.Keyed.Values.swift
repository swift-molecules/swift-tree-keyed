public import Storage_Generational
public import Store_Primitive

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func values(
        along keyPath: some Swift.Sequence<Key>
    ) -> [Value?] {
        guard let rootHandle = _rootHandle else { return [] }

        var result: [Value?] = []
        var currentHandle: Store.Generational.Handle? = rootHandle

        for key in keyPath {
            guard let handle = currentHandle else {
                result.append(nil)
                continue
            }

            if let childHandle = _childHandle(of: handle, key: key) {
                result.append(_value(of: childHandle))
                currentHandle = childHandle
            } else {
                result.append(nil)
                currentHandle = nil
            }
        }

        return result
    }
}
