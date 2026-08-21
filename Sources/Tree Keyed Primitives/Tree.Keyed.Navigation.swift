extension __Tree where S: __TreeKeyedStorage {

    @inlinable
    public func key(of position: Position) -> Key? {
        guard let handle = _liveHandle(position) else { return nil }
        return _parentKey(of: handle)
    }

    @inlinable
    public func children(of position: Position) -> [(key: Key, position: Position)]? {
        guard let handle = _liveHandle(position) else { return nil }
        var result: [(key: Key, position: Position)] = []
        for (key, childHandle) in _children(of: handle) {
            result.append((key, _position(of: childHandle)))
        }
        return result
    }

    @inlinable
    public func children(
        of position: Position,
        _ body: (Key, Position) -> Void
    ) {
        guard let handle = _liveHandle(position) else { return }
        for (key, childHandle) in _children(of: handle) {
            body(key, _position(of: childHandle))
        }
    }
}
