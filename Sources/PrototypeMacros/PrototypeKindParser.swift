import Foundation
import PrototypeAPI
import SwiftSyntax

extension PrototypeKind {
    public init(from expression: LabeledExprSyntax) throws {
        let identifier = expression
            .expression
            .as(MemberAccessExprSyntax.self)?
            .declName
            .baseName
            .trimmed
            .text
        
        guard let identifier, let kind = Self(rawValue: identifier) else {
            throw PrototypeMacrosError.invalid(argument: expression.description, givenForArgument: .kinds, ofMacro: .prototype)
        }
        
        self = kind
    }
}
