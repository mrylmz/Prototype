import Foundation
import PrototypeAPI

@attached(peer, names: suffixed(Form), suffixed(View), suffixed(SettingsView))
public macro Field(
    _ attributes: FieldAttribute...
) = #externalMacro(module: "PrototypeMacros", type: "FieldMacro")
