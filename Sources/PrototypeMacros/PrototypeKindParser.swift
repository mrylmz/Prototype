import Foundation
import PrototypeAPI
import SwiftSyntax

extension PrototypeKind {
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
            throw PrototypeMacrosError.invalidPrototypeKindsArgument
        }
        
        self = kind
    }
}
