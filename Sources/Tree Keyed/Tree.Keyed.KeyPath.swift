public import Storage_Generational
public import Store_Primitive
public import Tree

extension __Tree where S: __TreeKeyedStorage {

    @inlinable
    public func keyPath(to position: Position) -> [Key]? {
        guard let handle = _liveHandle(position) else { return nil }

        var path: [Key] = []
        var current = handle

        while let parentKey = _parentKey(of: current) {
            path.append(parentKey)
            guard let parentHandle = _parentHandle(of: current) else {
                break
            }
            current = parentHandle
        }

        path.reverse()
        return path
    }

    @inlinable
    public func position(at keyPath: some Swift.Sequence<Key>) -> Position? {
        guard let rootHandle = _rootHandle else { return nil }

        var current = rootHandle
        for key in keyPath {
            guard let childHandle = _childHandle(of: current, key: key) else {
                return nil
            }
            current = childHandle
        }

        return _position(of: current)
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func value(at keyPath: some Swift.Sequence<Key>) -> Value? {
        guard let pos = position(at: keyPath) else { return nil }
        return peek(at: pos)
    }

    @inlinable
    public mutating func update(
        _ newValue: Value,
        at keyPath: some Swift.Sequence<Key>
    ) throws(Self.Error) {
        guard let pos = position(at: keyPath) else {
            throw .invalidPosition
        }
        try update(at: pos, newValue)
    }

    @inlinable
    @discardableResult
    public mutating func insert(
        _ value: Value,
        at keyPath: [Key],
        intermediateValue: (Key) -> Value
    ) throws(Self.Error) -> Position {
        precondition(!keyPath.isEmpty, "Key path must not be empty")

        let rootHandle: Store.Generational.Handle
        if let existing = _rootHandle {
            rootHandle = existing
        } else {
            rootHandle = _insertNode(intermediateValue(keyPath[0]), parent: nil)
            _rootHandle = rootHandle
        }

        var currentHandle = rootHandle

        for i in keyPath.indices.dropLast() {
            let key = keyPath[i]
            if let childHandle = _childHandle(of: currentHandle, key: key) {
                currentHandle = childHandle
            } else {
                let handle = _insertNode(intermediateValue(key), parent: currentHandle)
                _linkChild(handle, to: currentHandle, at: key)
                currentHandle = handle
            }
        }

        guard let terminalKey = keyPath.last else {
            preconditionFailure("Key path must not be empty")
        }
        guard let existingChild = _childHandle(of: currentHandle, key: terminalKey) else {
            let handle = _insertNode(value, parent: currentHandle)
            _linkChild(handle, to: currentHandle, at: terminalKey)
            return _position(of: handle)
        }
        _setValue(at: existingChild, value)
        return _position(of: existingChild)
    }
}
