extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @_disfavoredOverload
    @inlinable
    public subscript(keyPath: [Key]) -> Value? {
        value(at: keyPath)
    }

    @_disfavoredOverload
    @inlinable
    public subscript(keyPath: Key...) -> Value? {
        self[keyPath]
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public subscript<U>(keyPath: [Key]) -> U? where Value == U? {
        get {

            value(at: keyPath) ?? nil
        }
        set {

            if keyPath.isEmpty {
                if root != nil {
                    do throws(Self.Error) {
                        try update(newValue, at: keyPath)
                    } catch {

                    }
                } else {
                    do throws(Self.Error) {
                        _ = try insert(newValue, at: Insert.Position.root)
                    } catch {

                    }
                }
            } else {
                do throws(Self.Error) {
                    _ = try insert(newValue, at: keyPath)
                } catch {

                }
            }
        }
    }

    @inlinable
    public subscript<U>(keyPath: Key...) -> U? where Value == U? {
        get { self[keyPath] }
        set { self[keyPath] = newValue }
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    @discardableResult
    public mutating func insert<U>(
        _ value: U?,
        at keyPath: [Key]
    ) throws(Self.Error) -> Position where Value == U? {
        if keyPath.isEmpty {
            guard let root else {
                return try insert(value, at: Insert.Position.root)
            }
            try update(value, at: keyPath)
            return root
        }
        return try insert(value, at: keyPath, intermediateValue: { _ in nil })
    }
}
