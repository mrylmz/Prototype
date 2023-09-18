import Foundation
import PrototypeAPI
import PrototypeMacros

@attached(peer, names: suffixed(Form), suffixed(View))
public macro Prototype(
    style: PrototypeStyle = .default,
    kinds firstKind: PrototypeKind,
    _ otherKinds: PrototypeKind...
) = #externalMacro(module: "PrototypeMacros", type: "PrototypeMacro")
