public struct __TreeKeyedDiff<Key: Swift.Hashable, Value: Equatable> {

    public let operations: [Operation]

    public init(operations: [Operation]) {
        self.operations = operations
    }

    public var isEmpty: Bool { operations.isEmpty }
}

extension __TreeKeyedDiff: Sendable where Key: Sendable, Value: Sendable {}

extension __TreeKeyedDiff: Equatable where Key: Equatable {}

extension __Tree where S: __TreeKeyedStorage, S.Element: Equatable & Copyable {

    public typealias Diff = __TreeKeyedDiff<Key, Value>
}
