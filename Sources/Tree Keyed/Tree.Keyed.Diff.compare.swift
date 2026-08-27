extension __Tree where S: __TreeKeyedStorage, S.Element: Equatable & Copyable {

    public static func diff(
        from old: borrowing Self,
        to new: borrowing Self
    ) -> __TreeKeyedDiff<Key, Value> {
        typealias Operation = __TreeKeyedDiff<Key, Value>.Operation
        var operations: [Operation] = []

        switch (old.root, new.root) {
        case (nil, nil):
            break

        case (nil, let newRoot?):
            _collectSubtree(
                of: new,
                at: newRoot,
                path: []
            ) { operations.append(.added(path: $0, value: $1)) }

        case (let oldRoot?, nil):
            _collectSubtree(
                of: old,
                at: oldRoot,
                path: []
            ) { operations.append(.removed(path: $0, value: $1)) }

        case (let oldRoot?, let newRoot?):

            if let oldValue = old.peek(at: oldRoot),
                let newValue = new.peek(at: newRoot),
                oldValue != newValue
            {
                operations.append(.modified(path: [], old: oldValue, new: newValue))
            }

            var pending:
                [(
                    oldPos: Position,
                    newPos: Position,
                    path: [Key]
                )] = [(oldRoot, newRoot, [])]

            while let (oldPos, newPos, path) = pending.popLast() {
                let oldChildren = old.children(of: oldPos) ?? []
                let newChildren = new.children(of: newPos) ?? []

                for (key, oldChildPos) in oldChildren {
                    let childPath = path + [key]

                    if let newChildPos = new.child.at(key, of: newPos) {

                        if let oldValue = old.peek(at: oldChildPos),
                            let newValue = new.peek(at: newChildPos),
                            oldValue != newValue
                        {
                            operations.append(
                                .modified(path: childPath, old: oldValue, new: newValue)
                            )
                        }
                        pending.append((oldChildPos, newChildPos, childPath))
                    } else {

                        _collectSubtree(
                            of: old,
                            at: oldChildPos,
                            path: childPath
                        ) { operations.append(.removed(path: $0, value: $1)) }
                    }
                }

                for (key, newChildPos) in newChildren {
                    if old.child.at(key, of: oldPos) == nil {
                        let childPath = path + [key]
                        _collectSubtree(
                            of: new,
                            at: newChildPos,
                            path: childPath
                        ) { operations.append(.added(path: $0, value: $1)) }
                    }
                }
            }
        }

        return .init(operations: operations)
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @usableFromInline
    static func _collectSubtree(
        of tree: borrowing Self,
        at position: Position,
        path: [Key],
        emit: ([Key], Value) -> Void
    ) {
        var pending: [(position: Position, path: [Key])] = [(position, path)]

        while let (pos, currentPath) = pending.popLast() {
            if let value = tree.peek(at: pos) {
                emit(currentPath, value)
            }

            if let children = tree.children(of: pos) {

                for (key, childPos) in children.reversed() {
                    pending.append((childPos, currentPath + [key]))
                }
            }
        }
    }
}
