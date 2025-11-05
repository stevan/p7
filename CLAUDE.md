# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

p7 is an experimental Perl project that implements a Java-inspired module system with functional programming utilities. The codebase uses Perl 5.40's new class syntax and experimental features to create a Stream API, reactive Flow framework, functional interfaces, and compiler introspection tools.

## Running Tests

Run a single test file:
```bash
perl -Ilib t/path/to/test.t
```

Run all tests in a directory:
```bash
prove -l t/org/p7/util/stream/
```

Run all tests:
```bash
prove -lr t/
```

## Code Architecture

### Module System

The codebase implements a custom module system (`lib/module.pm`) inspired by Java packages:

- **Namespace Convention**: Modules use lowercase names following Java package conventions (e.g., `org::p7::util::stream`)
- **Module Declaration**: Each module directory has a base module class that inherits from `module`:
  ```perl
  class org::p7::util::stream :isa(module) {}
  ```
- **Loading Classes**: Use the module system to load classes within a module:
  ```perl
  use module qw[ org::p7::util::stream ];
  use org::p7::util::stream qw[ Stream ];
  ```
- **Lexical Imports**: All imports are lexical (file-scoped) and don't pollute namespaces
- **The `importer` Module**: Use `lib/importer.pm` for lexically importing functions from external packages

### Core Architectural Components

#### 1. Stream API (`lib/org/p7/util/stream/`)

A lazy, composable stream processing library inspired by Java Streams:

- **Core Class**: `Stream.pm` - main stream interface
- **Sources** (`Stream/Source/`): FromArray, FromIterator, FromRange, FromSupplier, FromArray::OfStreams
- **Operations** (`Stream/Operation/`): Map, Grep, FlatMap, Flatten, Reduce, ForEach, Collect, Take, TakeUntil, Peek, Every, When, Recurse, Gather, Match, Buffered
- **Collectors** (`Stream/Collectors.pm`): ToList, ToHash, etc.
- **Match System** (`Stream/Match.pm`, `Stream/Match/Builder.pm`): Pattern matching on streams

Key patterns:
- Streams are lazy and built as a chain with `prev` references
- Terminal operations (reduce, foreach, collect, match) trigger execution
- On open/close hooks allow lifecycle management

#### 2. Functional Interfaces (`lib/org/p7/util/function/`)

Wrapper classes for functional programming patterns:
- `BiConsumer.pm`, `BiFunction.pm` - Two-argument operations
- `Consumer.pm`, `Function.pm` - Single-argument operations
- `Predicate.pm` - Boolean test functions
- `Supplier.pm` - Generator functions
- `Comparator.pm` - Comparison functions

These wrap subroutine references and provide a consistent interface for stream operations.

#### 3. Reactive Flows (`lib/org/p7/util/concurrent/`)

A reactive streams implementation with:
- `Flow.pm` - Core reactive flow interface
- `Flow/Publisher.pm`, `Flow/Subscriber.pm`, `Flow/Subscription.pm` - Reactive streams components
- `Flow/Executor.pm` - Execution model for async operations
- `Flow/Operation/` - Map, Grep operations for flows

#### 4. IO Streams (`lib/org/p7/io/stream/`)

IO-specific stream sources:
- `IO/Stream/Source/BytesFromHandle.pm` - Read bytes from filehandles
- `IO/Stream/Source/LinesFromHandle.pm` - Read lines from filehandles
- `IO/Stream/Source/FilesFromDirectory.pm` - List files from directories
- `IO/Stream/Files.pm`, `IO/Stream/Directories.pm` - High-level file/directory streams

#### 5. Compiler Introspection (`lib/org/p7/core/compiler/`)

Tools for analyzing Perl code at compile time:
- `Decompiler.pm` - Converts CV references into streams of opcodes
- `Decompiler/Source/Optree.pm` - Stream source from optree
- `Decompiler/Context/` - Opcode and Statement context wrappers
- `Deparser.pm`, `Deparser/Tree.pm` - Parse tree reconstruction
- `Deparser/Event.pm`, `Deparser/Observer.pm` - Event-based parsing

Uses `B::save_BEGINs()` to preserve BEGIN blocks for analysis.

#### 6. Core Utilities (`lib/org/p7/core/util/`)

- `Logging.pm` - Logging infrastructure with DEBUG support
- `Exception.pm` - Exception handling with stack traces

### Namespace Patterns

Files use `'` as package separator in class declarations but `::` in use statements:
```perl
# File declaration
class org'p7'util'stream :isa(module) {}

# Import usage
use org::p7::util::stream qw[ Stream ];
```

### Important Module System Notes

From NOTES.md:
- Module imports are lexical and file-scoped
- Modules should declare their namespace using `use module qw[ ... ]`
- The module system pushes directories onto @INC (may need cleanup in the future)
- All module exports must use `builtin::export_lexically`
- Classes within a module can `use` each other as long as they declare their module

## Development Patterns

- Use `v5.40` and enable `experimental qw[ class ]` in all files
- Stream operations are chained and lazy - only execute on terminal operations
- Functional interfaces wrap bare subrefs for consistency
- All imports should be lexical to avoid namespace pollution
- Tests are organized to mirror the lib/ directory structure
