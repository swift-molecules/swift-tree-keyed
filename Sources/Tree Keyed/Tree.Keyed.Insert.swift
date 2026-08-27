public import Tree

public enum __TreeKeyedInsert<Key: Hash.`Protocol`> {

    public typealias Position = __TreeKeyedInsertPosition<Key>
}

extension __Tree where S: __TreeKeyedStorage {

    public typealias Insert = __TreeKeyedInsert<S.Address>
}

extension __Tree where S: __TreeKeyedStorage {

    @inlinable
    @discardableResult
    public mutating func insert(
        _ value: consuming Value,
        at position: Insert.Position
    ) throws(Self.Error) -> Position {
        switch position {
        case .root:
            do throws(__TreeError) {
                return try insert(value, at: __TreeInsertPosition<Key>.root)
            } catch {
                throw Self._map(error)
            }

        case .child(of: let parent, let key):
            do throws(__TreeError) {
                return try insert(value, at: __TreeInsertPosition<Key>.child(of: parent, at: key))
            } catch {
                throw Self._map(error, key: key)
            }
        }
    }

    @inlinable
    package static func _map(_ error: __TreeError, key: Key? = nil) -> __TreeKeyedError<Key> {
        switch error {
        case .slotOccupied: return key.map { .keyOccupied($0) } ?? .invalidPosition
        case .rootOccupied: return .rootOccupied
        case .invalidPosition: return .invalidPosition
        case .cannotRemoveNonLeaf: return .cannotRemoveNonLeaf
        case .childIndexOutOfBounds: return .invalidPosition
        }
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public var rootValue: Value? {
        get {
            guard let rootHandle = _rootHandle else { return nil }
            return _value(of: rootHandle)
        }
        set {
            guard let newValue else { return }
            if let rootHandle = _rootHandle {
                _setValue(at: rootHandle, newValue)
            } else {
                _rootHandle = _insertNode(newValue, parent: nil)
            }
        }
    }

    @inlinable
    public mutating func update(
        at position: Position,
        _ newValue: Value
    ) throws(Self.Error) {
        guard let handle = _liveHandle(position) else { throw .invalidPosition }
        _setValue(at: handle, newValue)
    }
}
