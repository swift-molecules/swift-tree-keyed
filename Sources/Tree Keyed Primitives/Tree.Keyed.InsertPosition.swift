public enum __TreeKeyedInsertPosition<Key: Hash.`Protocol`> {

    case root

    case child(of: __TreePosition, key: Key)
}

extension __TreeKeyedInsertPosition: Sendable where Key: Sendable {}
