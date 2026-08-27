extension __TreeKeyedDiff {

    public enum Operation {

        case added(path: [Key], value: Value)

        case removed(path: [Key], value: Value)

        case modified(path: [Key], old: Value, new: Value)
    }
}

extension __TreeKeyedDiff.Operation: Sendable where Key: Sendable, Value: Sendable {}

extension __TreeKeyedDiff.Operation: Equatable where Key: Equatable {}
