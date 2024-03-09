import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PrototypePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FieldMacro.self,
        PrototypeMacro.self,
        SectionMacro.self,
    ]
}
