import Foundation
import PrototypeAPI
import SwiftSyntax

extension FieldAttribute {
    public init(from expression: LabeledExprSyntax) throws {
        let identifier = expression
            .expression
            .as(MemberAccessExprSyntax.self)?
            .declName
            .baseName
            .trimmed
            .text
        
        guard let identifier, let attribute = Self(rawValue: identifier) else {
            throw PrototypeMacrosError.invalid(argument: expression.description, givenForArgument: .attributes, ofMacro: .field)
        }
        
        self = attribute
    }
}
