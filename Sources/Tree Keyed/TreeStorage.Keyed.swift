public import Dictionary_Ordered
public import Dictionary_Primitive
public import Hash_Indexed_Primitive
public import Hash
public import Index
public import Storage_Generational
public import Store_Primitive
public import Tree

extension TreeStorage {

    public struct Keyed<Element: ~Copyable, Key: Hash.`Protocol`>: ~Copyable {

        public typealias Address = Key

        public typealias Error = __TreeKeyedError<Key>

        @usableFromInline
        var _arena: __TreeArena<Element, __TreeKeyedLinks<Key>>

        @inlinable
        public init() { _arena = __TreeArena<Element, __TreeKeyedLinks<Key>>() }

        @inlinable
        public init(minimumCapacity: Index<Element>.Count) {
            _arena = __TreeArena<Element, __TreeKeyedLinks<Key>>(minimumCapacity: minimumCapacity)
        }

        @inlinable
        public init() where Element: Copyable {
            _arena = __TreeArena<Element, __TreeKeyedLinks<Key>>()
        }

        @inlinable
        public init(minimumCapacity: Index<Element>.Count) where Element: Copyable {
            _arena = __TreeArena<Element, __TreeKeyedLinks<Key>>(minimumCapacity: minimumCapacity)
        }
    }
}

extension TreeStorage.Keyed: __TreeStorage where Element: ~Copyable {

    @inlinable
    public var _count: Index<Element>.Count { _arena.count }

    @inlinable
    public var _rootHandle: Store.Generational.Handle? {
        get { _arena.rootHandle }
        set { _arena.rootHandle = newValue }
    }

    @inlinable
    public func _liveHandle(_ position: __TreePosition) -> Store.Generational.Handle? {
        _arena.liveHandle(position)
    }

    @inlinable
    public mutating func _insertNode(
        _ element: consuming Element,
        parent: Store.Generational.Handle?
    ) -> Store.Generational.Handle {
        _arena.insertNode(element, links: __TreeKeyedLinks<Key>(), parent: parent)
    }

    @inlinable
    public mutating func _removeNode(_ handle: Store.Generational.Handle) -> Element {
        _arena.removeNode(handle)
    }

    @inlinable
    public mutating func _removeAll() { _arena.removeAll() }

    @inlinable
    public func _parentHandle(of handle: Store.Generational.Handle) -> Store.Generational.Handle? {
        _arena.parentHandle(of: handle)
    }

    @inlinable
    public func _withElement<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (borrowing Element) -> R
    ) -> R {
        _arena.withElement(at: handle, body)
    }

    @inlinable
    public mutating func _withElementMut<R: ~Copyable>(
        at handle: Store.Generational.Handle,
        _ body: (inout Element) -> R
    ) -> R {
        _arena.withElementMut(at: handle, body)
    }

    @inlinable
    public func _childHandle(
        at handle: Store.Generational.Handle,
        address: Key
    ) -> Store.Generational.Handle? {
        _arena.withLinks(at: handle) { $0.children.withValue(forKey: address) { $0 } }
    }

    @inlinable
    public func _validateLink(
        to parent: Store.Generational.Handle,
        at address: Key
    ) throws(__TreeError) {
        let occupied = _arena.withLinks(at: parent) { $0.children.contains(key: address) }
        if occupied { throw .slotOccupied }
    }

    @inlinable
    public mutating func _linkChild(
        _ child: Store.Generational.Handle,
        to parent: Store.Generational.Handle,
        at address: Key
    ) {
        _arena.withLinksMut(at: parent) { _ = $0.children.insert(key: address, value: child) }
        _arena.withLinksMut(at: child) { $0.parentKey = address }
    }

    @inlinable
    public mutating func _unlinkChild(
        _ child: Store.Generational.Handle,
        from parent: Store.Generational.Handle
    ) {
        guard let key = _arena.withLinks(at: child, { $0.parentKey }) else { return }
        _arena.withLinksMut(at: parent) { _ = $0.children.removeValue(forKey: key) }
    }

    @inlinable
    public func _childCount(at handle: Store.Generational.Handle) -> Int {
        Int(bitPattern: _arena.withLinks(at: handle) { $0.children.count })
    }

    @inlinable
    public func _forEachChild(
        at handle: Store.Generational.Handle,
        _ body: (Store.Generational.Handle) -> Void
    ) {
        _arena.withLinks(at: handle) { links in
            links.children.forEach { _, child in body(child) }
        }
    }
}

extension TreeStorage.Keyed: __TreeKeyedStorage {

    @inlinable
    public func _parentKey(of handle: Store.Generational.Handle) -> Key? {
        _arena.withLinks(at: handle) { $0.parentKey }
    }

    @inlinable
    public func _children(
        of handle: Store.Generational.Handle
    ) -> [(key: Key, handle: Store.Generational.Handle)] {
        _arena.withLinks(at: handle) { links in
            var out: [(key: Key, handle: Store.Generational.Handle)] = []
            links.children.forEach { key, child in out.append((key, child)) }
            return out
        }
    }
}

extension TreeStorage.Keyed: Copyable where Element: Copyable {}

extension TreeStorage.Keyed: Sendable where Element: Sendable, Key: Sendable {}

extension __Tree where S: ~Copyable {

    @inlinable
    public init<Element: ~Copyable, Key: Hash.`Protocol`>()
    where S == TreeStorage.Keyed<Element, Key> {
        self.init(storage: TreeStorage.Keyed<Element, Key>())
    }

    @inlinable
    public init<Element: ~Copyable, Key: Hash.`Protocol`>(
        minimumCapacity: Index.Index<Element>.Count
    ) where S == TreeStorage.Keyed<Element, Key> {
        self.init(storage: TreeStorage.Keyed<Element, Key>(minimumCapacity: minimumCapacity))
    }

    @inlinable
    public init<Element, Key: Hash.`Protocol`>()
    where S == TreeStorage.Keyed<Element, Key> {
        self.init(storage: TreeStorage.Keyed<Element, Key>())
    }

    @inlinable
    public init<Element, Key: Hash.`Protocol`>(
        minimumCapacity: Index.Index<Element>.Count
    ) where S == TreeStorage.Keyed<Element, Key> {
        self.init(storage: TreeStorage.Keyed<Element, Key>(minimumCapacity: minimumCapacity))
    }

    @inlinable
    public init<Element, Key: Hash.`Protocol`>(rootValue: consuming Element)
    where S == TreeStorage.Keyed<Element, Key> {
        self.init(storage: TreeStorage.Keyed<Element, Key>())
        let handle = _storage._insertNode(rootValue, parent: nil)
        _storage._rootHandle = handle
    }
}
