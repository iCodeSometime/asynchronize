## 0.1.1
- Fixes a bug where old method_added would be called more than once

## 0.1.2
- Fixes a bug where method_added wouldn't be properly detected or called in
classes that defined method_added before including asynchronize.

## 0.2.0
- `:return_value` is now always set on the thread.
- Inheriting from a class that includes asynchronize no longer automatically
asynchronizes methods that override asynchronized methods in the parent class.
- various other bug fixes
