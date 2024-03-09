@attached(peer)
public macro Section(_ title: String = "") = #externalMacro(module: "PrototypeMacros", type: "SectionMacro")
