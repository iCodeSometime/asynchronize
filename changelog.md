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

## 0.2.1
- Memory usage optimizations

## 0.3.0
- Rewrite using Module.prepend.

## 0.4.0
- Update API to be more consistent with built in threads.
- Add ability to retrieve both post-block and pre-block data from thread.

## 0.4.1
- Update dependencies to latest version

