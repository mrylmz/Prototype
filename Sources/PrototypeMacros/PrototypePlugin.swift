import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct PrototypePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PrototypeMacro.self,
        SectionMacro.self,
        SecureMacro.self,
    ]
}
