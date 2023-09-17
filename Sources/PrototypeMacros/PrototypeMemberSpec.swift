import Foundation
import SwiftSyntax
import SwiftSyntaxExtensions

/*
 
    ClassDeclSyntax
    ├─name: identifier("Author")
    ╰─memberBlock: MemberBlockSyntax
        ├─leftBrace: leftBrace
        ├─members: MemberBlockItemListSyntax
        │ ╰─[0]: MemberBlockItemSyntax
        │   ╰─decl: VariableDeclSyntax
        │     ├─attributes: AttributeListSyntax
        │     ├─modifiers: DeclModifierListSyntax
        │     ├─bindingSpecifier: keyword(SwiftSyntax.Keyword.var)
        │     ╰─bindings: PatternBindingListSyntax
        │       ╰─[0]: PatternBindingSyntax
        │         ├─pattern: IdentifierPatternSyntax
        │         │ ╰─identifier: identifier("name")
        │         ├─typeAnnotation: TypeAnnotationSyntax
        │         │ ├─colon: colon
        │         │ ╰─type: IdentifierTypeSyntax
        │         │   ╰─name: identifier("String")
        │         ╰─initializer: InitializerClauseSyntax
        │           ├─equal: equal
        │           ╰─value: StringLiteralExprSyntax
        │             ├─openingQuote: stringQuote
        │             ├─segments: StringLiteralSegmentListSyntax
        │             │ ╰─[0]: StringSegmentSyntax
        │             │   ╰─content: stringSegment("")
        │             ╰─closingQuote: stringQuote
        ╰─rightBrace: rightBrace
 
 */

public struct PrototypeMemberAttributes: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension PrototypeMemberAttributes {
    public static let none: Self = .init(rawValue: 0)
    public static let visible: Self = .init(rawValue: 1 << 0)
    public static let modifiable: Self = .init(rawValue: 1 << 1)
    public static let secure: Self = .init(rawValue: 1 << 2)
}

public struct PrototypeMemberSpec {
    public let accessLevelModifiers: AccessLevelModifiers
    public let name: String
    public let type: String
    public let attributes: PrototypeMemberAttributes
    public let initializer: InitializerClauseSyntax?
    
    public init(
        accessLevelModifiers: AccessLevelModifiers,
        name: String,
        type: String,
        attributes: PrototypeMemberAttributes,
        initializer: InitializerClauseSyntax?
    ) {
        self.accessLevelModifiers = accessLevelModifiers
        self.name = name
        self.type = type
        self.attributes = attributes
        self.initializer = initializer
    }
    
    public init(parsing declaration: VariableDeclSyntax) throws {
        guard let binding = declaration.bindings.first else {
            throw PrototypeMacroError.missingMemberPatternBinding
        }
        
        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text else {
            throw PrototypeMacroError.unsupportedMemberPatternBinding
        }
        
        guard let typeAnnotation = binding.typeAnnotation else {
            throw PrototypeMacroError.missingMemberPatternTypeAnnotation(member: name)
        }
        
        guard let type = typeAnnotation.type.as(IdentifierTypeSyntax.self)?.name.trimmed.text else {
            throw PrototypeMacroError.unsupportedMemberPatternTypeAnnotation(type: typeAnnotation.type.description, member: name)
        }
        
        var attributes: PrototypeMemberAttributes = .visible
        if declaration.bindingSpecifier.tokenKind == .keyword(SwiftSyntax.Keyword.var) {
            if !declaration.accessLevelModifiers.contains(.privateSet) {
                attributes.insert(.modifiable)
            }
        }
        
        if declaration.accessLevelModifiers.contains(.private) {
            attributes.remove(.visible)
        }
        
        if declaration.hasAttribute(named: "Secure") {
            attributes.insert(.secure)
        }
        
        self.init(
            accessLevelModifiers: declaration.accessLevelModifiers,
            name: name,
            type: type,
            attributes: attributes,
            initializer: binding.initializer
        )
    }
}
