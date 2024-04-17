import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxExtensions

/// The peer macro implementation of the `@Format` macro.
public struct FormatMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(VariableDeclSyntax.self) else {
            throw PrototypeMacrosError.macro("Format", canOnlyBeAttachedTo: .variableDeclaration)
        }
        
        return []
    }
}
