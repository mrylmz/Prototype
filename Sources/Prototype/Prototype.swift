import Foundation

@attached(peer, names: suffixed(Form), suffixed(View))
public macro Prototype(
    _ firstKind: PrototypeKind,
    _ otherKinds: PrototypeKind...
) = #externalMacro(module: "PrototypeMacros", type: "PrototypeMacro")
