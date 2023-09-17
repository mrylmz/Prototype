import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxExtensions

public struct SecureMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw SecureMacroError.unsupportedPeerDeclaration
        }
        
        let type = declaration
            .as(VariableDeclSyntax.self)?
            .bindings
            .first?
            .typeAnnotation?
            .type
            .as(IdentifierTypeSyntax.self)?
            .name
            .trimmed
            .text
        
        guard let type, type == "String" else {
            throw SecureMacroError.unsupportedPeerDeclaration
        }
        
        return []
    }
}
