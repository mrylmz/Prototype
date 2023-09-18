import Foundation
import SwiftSyntax
import PrototypeAPI

public struct PrototypeArguments {
    public let style: PrototypeStyle
    public let kinds: Set<PrototypeKind>
    
    public init(from attribute: AttributeSyntax) throws {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self), !arguments.isEmpty else {
            throw PrototypeMacroError.missingPrototypeKindsArgument
        }
        
        /*
        Optional(LabeledExprSyntax
        ├─ label: identifier("style")
        ├─colon: colon
        ├─expression: MemberAccessExprSyntax
        │ ├─period: period
        │ ╰─declName: DeclReferenceExprSyntax
        │   ╰─baseName: identifier("labeled")
        ╰─trailingComma: comma)
         */
        let styleArgument = attribute.argument(labeled: "style")
        let styleIdentifier = styleArgument?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.trimmed.text
        
        /*
        LabeledExprSyntax
        ├─label: identifier("kinds")
        ├─colon: colon
        ├─expression: MemberAccessExprSyntax
        │ ├─period: period
        │ ╰─declName: DeclReferenceExprSyntax
        │   ╰─baseName: identifier("form")
        ╰─trailingComma: comma
         */
        guard let firstKindsArgument = attribute.argument(labeled: "kinds") else {
            throw PrototypeMacroError.missingPrototypeKindsArgument
        }
        
        /*
        [
            LabeledExprSyntax
            ╰─expression: MemberAccessExprSyntax
              ├─period: period
              ╰─declName: DeclReferenceExprSyntax
                ╰─baseName: identifier("view")
        ]
         */
        let otherKindsArguments = attribute.arguments(after: firstKindsArgument)
        let allKindsArguments = [firstKindsArgument] + otherKindsArguments
        let parsedPrototypeKinds = try allKindsArguments.map(PrototypeKind.init(from:))
        let distinctPrototypeKinds = Set(parsedPrototypeKinds)
        
        guard parsedPrototypeKinds.count == Set(parsedPrototypeKinds).count else {
            throw PrototypeMacroError.duplicatePrototypeKindArgument
        }
        
        self.style = styleIdentifier.flatMap { PrototypeStyle(rawValue: $0) } ?? PrototypeStyle.default
        self.kinds = distinctPrototypeKinds
    }
}


extension PrototypeMacro {
    private static let prototypeKindIdentifierForm: String = "form"
    private static let prototypeKindIdentifierView: String = "view"

    private static func parsePrototypeKinds(from attribute: AttributeSyntax) throws -> [String] {
        guard
            let arguments = attribute.arguments?.as(LabeledExprListSyntax.self),
            !arguments.isEmpty
        else {
            throw PrototypeMacroError.missingPrototypeKindsArgument
        }
        
        let validPrototypeKinds = [prototypeKindIdentifierForm, prototypeKindIdentifierView]
        let parsedPrototypeKinds = try arguments.map { element in
            let identifier = element
                .expression
                .as(MemberAccessExprSyntax.self)?
                .declName
                .baseName
                .trimmed
                .text
            
            guard let identifier, validPrototypeKinds.contains(identifier) else {
                throw PrototypeMacroError.invalidPrototypeKindsArgument
            }
            
            return identifier
        }
        
        let distinctPrototypeKinds = Set(parsedPrototypeKinds)
        
        guard parsedPrototypeKinds.count == distinctPrototypeKinds.count else {
            throw PrototypeMacroError.duplicatePrototypeKindArgument
        }
        
        return parsedPrototypeKinds
    }
}
