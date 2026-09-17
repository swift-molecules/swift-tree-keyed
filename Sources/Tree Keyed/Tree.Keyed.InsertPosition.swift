public enum __TreeKeyedInsertPosition<Key: Swift.Hashable> {

    case root

    case child(of: __TreePosition, key: Key)
}

extension __TreeKeyedInsertPosition: Sendable where Key: Sendable {}
