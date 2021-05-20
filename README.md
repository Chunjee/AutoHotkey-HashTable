hashtable.ahk
=========

hashtable is an improvement on storing items in AutoHotkey Objects.

With hashtable you can
* store any string key without losing access to hashtable's methods
* prevent string keys from being case-folded
* prevent floating point number keys from being indexed by their current string representation instead of their value

:warning: Hash tables are inherently unordered.  When enumerating a hash table, do not expect to process keys in sorted order or the order they were inserted.  If you need to process keys in a certain order, store them in that order in an Array and enumerate that while operating on the hashtable or use something other than a hash table (like an [AVL tree](https://en.wikipedia.org/wiki/AVL_tree)).

:warning: Mutating a hash table while enumerating it might cause items to be processed more than once or skipped.  You can get the desired effect by enumerating a clone of the hashtable while mutating the hashtable you intend to keep.

:warning: Floating point number keys are rarely useful because it is rarely safe to compare the result of a floating point calculation exactly.  Converting mathematical constants to their names is an example of a valid use.

:warning: Object keys are rarely useful because they are indexed by their address.  Two objects might behave identically in every way, but if they are not the *same* object (stored in the same location in memory), they will not be associated with the same value.  Recording visited nodes in a graph traversal algorithm is an example of a valid use.

hashtable is compatible with AutoHotkey v1.


## Installation

`export.ahk` must be included explicitly or placed in a [library directory](https://autohotkey.com/docs/Functions.htm#lib).


## Usage

hashtable’s constructor accepts items as Arrays containing a key and a value, in that order.

hashtable is generally used with the following two methods:
```AutoHotkey
hashtable.create(Key, Value)
hashtable.read(Key)
```

`create(Key, Value)` writes the value associated with a key.

`read(Key)` reads the value associated with a key.

Supports the following interfaces from [Object](https://autohotkey.com/docs/objects/Object.htm):
```AutoHotkey
hashtable.delete(Key)
hashtable.count()
hashtable._NewEnum()
hashtable.hasKey(Key)
hashtable.clone()
```


## API
Follows CRUD operations (create, read, update, delete)


### Create
`.create`

### Read
`.read`

### Update
`.update`

### Delete
`.delete` and `.clear`

### Util
`.clone`, `.hasKey`, and `.size`
