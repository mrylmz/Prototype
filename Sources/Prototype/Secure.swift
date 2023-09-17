import Foundation

@attached(peer)
public macro Secure() = #externalMacro(module: "PrototypeMacros", type: "SecureMacro")
