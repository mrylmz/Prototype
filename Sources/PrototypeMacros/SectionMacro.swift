import SwiftSyntax
import SwiftSyntaxMacros

/// The peer macro implementation of the `@Section` macro.
public struct SectionMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(VariableDeclSyntax.self) else {
            throw PrototypeMacrosError.macro("Section", canOnlyBeAttachedTo: .variableDeclaration)
        }
        
        return []
    }
}
