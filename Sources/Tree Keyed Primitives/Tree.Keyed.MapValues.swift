public import Stack_Primitive
public import Storage_Generational_Primitives
public import Store_Primitive

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func mapValues<U>(_ transform: (Value) -> U) -> Tree<U>.Keyed<Key> {
        var result = Tree<U>.Keyed<Key>()
        guard let rootHandle = _rootHandle else { return result }

        var pending = Stack<
            (
                source: Store.Generational.Handle, parentHandle: Store.Generational.Handle?,
                parentKey: Key?
            )
        >()
        pending.push((rootHandle, nil, nil))

        while let (sourceHandle, destParentHandle, key) = pending.pop() {
            let newValue = transform(_value(of: sourceHandle))

            let handle = result._insertNode(newValue, parent: destParentHandle)

            if let destParentHandle, let key {
                result._linkChild(handle, to: destParentHandle, at: key)
            } else {
                result._rootHandle = handle
            }

            let children = _children(of: sourceHandle)
            for i in (0..<children.count).reversed() {
                pending.push((children[i].handle, handle, children[i].key))
            }
        }

        return result
    }

    @inlinable
    public func mapValues<U, E>(
        _ transform: ([Key], Value) throws(E) -> U
    ) throws(E) -> Tree<U>.Keyed<Key> {
        try compactMapValues { path, value throws(E) -> U? in
            try transform(path, value)
        }
    }

    @inlinable
    public func mapValues<U, E>(
        _ transform: ([Key], Value) throws(E) -> (U, recursivelyApply: Bool)
    ) throws(E) -> Tree<U>.Keyed<Key> {
        try compactMapValues { path, value throws(E) in
            try transform(path, value) as (U, recursivelyApply: Bool)?
        }
    }

    @inlinable
    public func compactMapValues<U, E>(
        _ transform: ([Key], Value) throws(E) -> U?
    ) throws(E) -> Tree<U>.Keyed<Key> {
        try compactMapValues { path, value throws(E) in
            try transform(path, value).map { ($0, recursivelyApply: false) }
        }
    }

    @inlinable
    public func compactMapValues<U, E>(
        _ transform: ([Key], Value) throws(E) -> (U, recursivelyApply: Bool)?
    ) throws(E) -> Tree<U>.Keyed<Key> {
        var result = Tree<U>.Keyed<Key>()
        guard let rootHandle = _rootHandle else { return result }

        var pending = Stack<
            (
                source: Store.Generational.Handle,
                destParent: Store.Generational.Handle?,
                parentKey: Key?,
                path: [Key],
                broadcast: U?
            )
        >()
        pending.push((rootHandle, nil, nil, [], nil))

        while let (sourceHandle, destParentHandle, key, path, broadcast) = pending.pop() {
            let newValue: U
            let shouldBroadcast: Bool

            if let broadcastValue = broadcast {
                newValue = broadcastValue
                shouldBroadcast = true
            } else {
                guard let transformed = try transform(path, _value(of: sourceHandle)) else {
                    continue
                }
                newValue = transformed.0
                shouldBroadcast = transformed.recursivelyApply
            }

            let handle = result._insertNode(newValue, parent: destParentHandle)

            if let destParentHandle, let key {
                result._linkChild(handle, to: destParentHandle, at: key)
            } else {
                result._rootHandle = handle
            }

            let children = _children(of: sourceHandle)
            for i in (0..<children.count).reversed() {
                var childPath = path
                childPath.append(children[i].key)
                pending.push(
                    (
                        children[i].handle,
                        handle,
                        children[i].key,
                        childPath,
                        shouldBroadcast ? newValue : nil
                    )
                )
            }
        }

        return result
    }

    @inlinable
    public func compactMapValues<U>(_ transform: (Value) -> U?) -> Tree<U>.Keyed<Key> {
        var result = Tree<U>.Keyed<Key>()
        guard let rootHandle = _rootHandle else { return result }

        guard let rootValue = transform(_value(of: rootHandle)) else { return result }

        let rootDest = result._insertNode(rootValue, parent: nil)
        result._rootHandle = rootDest

        var pending = Stack<
            (source: Store.Generational.Handle, destParent: Store.Generational.Handle)
        >()
        pending.push((rootHandle, rootDest))

        while let (sourceHandle, destParentHandle) = pending.pop() {
            for (childKey, childHandle) in _children(of: sourceHandle) {
                guard let childValue = transform(_value(of: childHandle)) else { continue }

                let childDest = result._insertNode(childValue, parent: destParentHandle)
                result._linkChild(childDest, to: destParentHandle, at: childKey)

                pending.push((childHandle, childDest))
            }
        }

        return result
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public func mapValues<U, E>(
        _ transform: ([Key], Value) async throws(E) -> U
    ) async throws(E) -> Tree<U>.Keyed<Key> {
        try await compactMapValues { path, value async throws(E) -> U? in
            try await transform(path, value)
        }
    }

    @inlinable
    public func mapValues<U, E>(
        _ transform: ([Key], Value) async throws(E) -> (U, recursivelyApply: Bool)
    ) async throws(E) -> Tree<U>.Keyed<Key> {
        try await compactMapValues { path, value async throws(E) in
            try await transform(path, value) as (U, recursivelyApply: Bool)?
        }
    }

    @inlinable
    public func compactMapValues<U, E>(
        _ transform: ([Key], Value) async throws(E) -> U?
    ) async throws(E) -> Tree<U>.Keyed<Key> {
        try await compactMapValues { path, value async throws(E) in
            try await transform(path, value).map { ($0, recursivelyApply: false) }
        }
    }

    @inlinable
    public func compactMapValues<U, E>(
        _ transform: ([Key], Value) async throws(E) -> (U, recursivelyApply: Bool)?
    ) async throws(E) -> Tree<U>.Keyed<Key> {
        var result = Tree<U>.Keyed<Key>()
        guard let rootHandle = _rootHandle else { return result }

        var pending = Stack<
            (
                source: Store.Generational.Handle,
                destParent: Store.Generational.Handle?,
                parentKey: Key?,
                path: [Key],
                broadcast: U?
            )
        >()
        pending.push((rootHandle, nil, nil, [], nil))

        while let (sourceHandle, destParentHandle, key, path, broadcast) = pending.pop() {
            let newValue: U
            let shouldBroadcast: Bool

            if let broadcastValue = broadcast {
                newValue = broadcastValue
                shouldBroadcast = true
            } else {
                guard let transformed = try await transform(path, _value(of: sourceHandle)) else {
                    continue
                }
                newValue = transformed.0
                shouldBroadcast = transformed.recursivelyApply
            }

            let handle = result._insertNode(newValue, parent: destParentHandle)

            if let destParentHandle, let key {
                result._linkChild(handle, to: destParentHandle, at: key)
            } else {
                result._rootHandle = handle
            }

            let children = _children(of: sourceHandle)
            for i in (0..<children.count).reversed() {
                var childPath = path
                childPath.append(children[i].key)
                pending.push(
                    (
                        children[i].handle,
                        handle,
                        children[i].key,
                        childPath,
                        shouldBroadcast ? newValue : nil
                    )
                )
            }
        }

        return result
    }
}
