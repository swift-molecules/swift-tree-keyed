public import Storage_Generational_Primitives
public import Store_Primitive
public import Tree_Primitives

extension __Tree where S: __TreeKeyedStorage {

    public typealias Value = S.Element

    public typealias Key = S.Address

    @usableFromInline
    var _rootHandle: Store.Generational.Handle? {
        @inlinable get { _storage._rootHandle }
        @inlinable set { _storage._rootHandle = newValue }
    }

    @inlinable
    package func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _storage._parentHandle(of: handle)
    }

    @inlinable
    package func _parentKey(of handle: Store.Generational.Handle) -> Key? {
        _storage._parentKey(of: handle)
    }

    @inlinable
    package func _children(
        of handle: Store.Generational.Handle
    ) -> [(key: Key, handle: Store.Generational.Handle)] {
        _storage._children(of: handle)
    }

    @inlinable
    package func _childHandle(
        of handle: Store.Generational.Handle,
        key: Key
    ) -> Store.Generational.Handle? {
        _storage._childHandle(at: handle, address: key)
    }

    @inlinable
    package mutating func _insertNode(
        _ value: consuming Value,
        parent: Store.Generational.Handle?
    ) -> Store.Generational.Handle {
        _storage._insertNode(value, parent: parent)
    }

    @inlinable
    package mutating func _linkChild(
        _ child: Store.Generational.Handle,
        to parent: Store.Generational.Handle,
        at key: Key
    ) {
        _storage._linkChild(child, to: parent, at: key)
    }
}

extension __Tree where S: __TreeKeyedStorage, S.Element: Copyable {

    @inlinable
    package func _value(of handle: Store.Generational.Handle) -> Value {
        _storage._withElement(at: handle) { $0 }
    }

    @inlinable
    package mutating func _setValue(at handle: Store.Generational.Handle, _ value: Value) {
        _storage._withElementMut(at: handle) { $0 = value }
    }
}
