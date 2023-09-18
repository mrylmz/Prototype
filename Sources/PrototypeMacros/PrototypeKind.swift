import Foundation
import SwiftSyntax

public enum PrototypeKind: String, CaseIterable {
    case view
    case form
    
    public init(from expression: LabeledExprSyntax) throws {
        /*
         LabeledExprSyntax
         ╰─expression: MemberAccessExprSyntax
           ├─period: period
           ╰─declName: DeclReferenceExprSyntax
             ╰─baseName: identifier("<#identifier#>")
         */
        let identifier = expression
            .expression
            .as(MemberAccessExprSyntax.self)?
            .declName
            .baseName
            .trimmed
            .text
        
        guard let identifier, let kind = Self(rawValue: identifier) else {
            throw PrototypeMacroError.invalidPrototypeKindsArgument
        }
        
        self = kind
    }
}
