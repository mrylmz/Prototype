import Foundation
import SwiftSyntax
import SwiftSyntaxExtensions

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
    public static let section: Self = .init(rawValue: 1 << 3)
    public static let description: Self = .init(rawValue: 1 << 4)
}

public struct PrototypeMemberSpec {
    public let accessLevelModifiers: AccessLevelModifiers
    public let name: String
    public let type: PrototypeTypeSpec
    public let initializer: InitializerClauseSyntax?
    public let attributes: PrototypeMemberAttributes
    public let sectionTitle: String?
    public let descriptionTitle: String?
    
    public init(
        accessLevelModifiers: AccessLevelModifiers,
        name: String,
        type: PrototypeTypeSpec,
        initializer: InitializerClauseSyntax?,
        attributes: PrototypeMemberAttributes,
        sectionTitle: String?,
        descriptionTitle: String?
    ) {
        self.accessLevelModifiers = accessLevelModifiers
        self.name = name
        self.type = type
        self.initializer = initializer
        self.attributes = attributes
        self.sectionTitle = sectionTitle
        self.descriptionTitle = descriptionTitle
    }
    
    public init(parsing binding: PatternBindingListSyntax.Element, of declaration: VariableDeclSyntax) throws {
        guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed.text else {
            throw PrototypeMacrosError.unsupportedPatternBinding(binding.pattern.description, givenInMemberListOfMacro: .prototype)
        }
        
        guard let typeAnnotation = binding.typeAnnotation else {
            throw PrototypeMacrosError.missingSyntax(.typeAnnotation, forMember: name, ofMacro: .prototype)
        }
        
        guard let type = PrototypeTypeSpec(parsing: typeAnnotation) else {
            throw PrototypeMacrosError.unsupportedType(typeAnnotation.type.description, forMember: name, ofMacro: .prototype)
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
        
        let sectionTitle = declaration
            .attribute(named: "Section")?
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.as(LabeledExprSyntax.self)?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?
            .content
            .text
        
        if sectionTitle != nil {
            attributes.insert(.section)
        }
        
        let descriptionTitle = declaration
            .attribute(named: "Description")?
            .arguments?.as(LabeledExprListSyntax.self)?
            .first?.as(LabeledExprSyntax.self)?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?
            .content
            .text
        
        if descriptionTitle != nil {
            attributes.insert(.description)
        }
        
        self.init(
            accessLevelModifiers: declaration.accessLevelModifiers,
            name: name,
            type: type,
            initializer: binding.initializer,
            attributes: attributes,
            sectionTitle: sectionTitle,
            descriptionTitle: descriptionTitle
        )
    }
}
