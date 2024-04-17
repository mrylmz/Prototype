import Foundation
import PrototypeAPI

@attached(peer, names: suffixed(Form), suffixed(View), suffixed(SettingsView))
public macro Format<F>(
    using: F
) = #externalMacro(
    module: "PrototypeMacros",
    type: "FormatMacro"
) where F : FormatStyle, F.FormatInput : Equatable, F.FormatOutput == String
