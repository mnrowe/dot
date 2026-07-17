# C# / .NET standards

Canonical sources:
- C# coding conventions (Microsoft):
  https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions
- .NET runtime coding style:
  https://github.com/dotnet/runtime/blob/main/docs/coding-guidelines/coding-style.md
- Framework design guidelines:
  https://learn.microsoft.com/dotnet/standard/design-guidelines/

## Tooling
- Format with **`dotnet format`**; honor the repo's `.editorconfig`.
- Enable **nullable reference types** (`<Nullable>enable</Nullable>`) and treat
  warnings seriously. Enable analyzers (`<EnableNETAnalyzers>true`).

## Naming & style
- `PascalCase` for types, methods, properties, constants, and public members;
  `camelCase` for locals and parameters; `_camelCase` for private fields.
- Interfaces prefixed `I` (`IRepository`). Async methods suffixed `Async`.
- `var` when the type is obvious from the right-hand side; explicit otherwise.
- One type per file; file name matches the type.
- Prefer expression-bodied members for trivial ones; braces on their own lines.

## Idioms
- Prefer `async`/`await` end-to-end; **never** `.Result` / `.Wait()` (deadlocks).
  Pass `CancellationToken` through async APIs.
- `using` declarations/statements for `IDisposable`; dispose what you own.
- LINQ for queries/transforms when it reads clearly; a loop when it doesn't.
- Records for immutable data; pattern matching over long `if/else` chains.
- Throw specific exceptions; don't catch `Exception` unless you rethrow/log.
- Return `IEnumerable`/`IReadOnlyList` from public APIs, not mutable `List`.

## Correctness & safety
- Validate public method arguments (`ArgumentNullException.ThrowIfNull`).
- Parameterize all SQL (or use EF Core); never concatenate user input.
- Prefer `System.Text.Json`; dispose `HttpClient` via `IHttpClientFactory`, not
  per-call `new HttpClient()`.
