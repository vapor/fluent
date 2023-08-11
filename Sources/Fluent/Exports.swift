#if swift(>=5.8)

@_documentation(visibility: internal) @_exported import FluentKit

#else

@_exported import FluentKit

#endif

infix operator ~~
infix operator =~
infix operator !~
infix operator !=~
infix operator !~=
