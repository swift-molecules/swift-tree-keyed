public enum __TreeKeyedError<Key: Hash.`Protocol`>: Swift.Error {

    case invalidPosition

    case rootOccupied

    case keyOccupied(Key)

    case cannotRemoveNonLeaf
}

extension __TreeKeyedError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .invalidPosition:
            return "invalid position"

        case .rootOccupied:
            return "root position is already occupied"

        case .keyOccupied(let key):
            return "child key '\(key)' is already occupied"

        case .cannotRemoveNonLeaf:
            return "cannot remove non-leaf node; use removeSubtree instead"
        }
    }
}

extension __TreeKeyedError: Sendable where Key: Sendable {}
