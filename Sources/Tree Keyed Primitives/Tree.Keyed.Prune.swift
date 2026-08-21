public import Stack_Primitive
public import Storage_Generational_Primitives
public import Store_Primitive
import Tree_Primitives

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    public mutating func prune(where shouldRemove: (Value) -> Bool) {
        guard let rootHandle = _rootHandle else { return }

        if shouldRemove(_value(of: rootHandle)) {

            if let root = self.root {
                do throws(__TreeError) {
                    try removeSubtree(at: root)
                } catch {

                }
            }
            return
        }

        var toPrune: [(parentHandle: Store.Generational.Handle, key: Key)] = []
        var pending = Stack<Store.Generational.Handle>()
        pending.push(rootHandle)

        while let handle = pending.pop() {
            for (childKey, childHandle) in _children(of: handle) {
                if shouldRemove(_value(of: childHandle)) {
                    toPrune.append((parentHandle: handle, key: childKey))
                } else {
                    pending.push(childHandle)
                }
            }
        }

        for (parentHandle, key) in toPrune.reversed() {
            guard let childHandle = _childHandle(of: parentHandle, key: key) else { continue }
            do throws(__TreeError) {
                try removeSubtree(at: _position(of: childHandle))
            } catch {

            }
        }
    }
}
