import Foundation
import SwiftSyntax
import SwiftSyntaxExtensions

public struct PrototypeSpec {
    public let accessLevelModifiers: AccessLevelModifiers
    public let name: String
    public let members: [PrototypeMemberSpec]
    
    public init(accessLevelModifiers: AccessLevelModifiers, name: String, members: [PrototypeMemberSpec]) {
        self.accessLevelModifiers = accessLevelModifiers
        self.name = name
        self.members = members
    }
    
    /*
        ClassDeclSyntax
        ├─name: identifier("Author")
        ├─modifiers: DeclModifierListSyntax
        │ ╰─[0]: DeclModifierSyntax
        │   ╰─name: keyword(SwiftSyntax.Keyword.public)
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
    public init(parsing declaration: some DeclSyntaxProtocol) throws {
        if let declaration = declaration.as(ClassDeclSyntax.self) {
            try self.init(parsing: declaration)
        } else if let declaration = declaration.as(StructDeclSyntax.self) {
            try self.init(parsing: declaration)
        } else {
            throw PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration)
        }
    }
    
    public init(parsing declaration: ClassDeclSyntax) throws {
        let members: [PrototypeMemberSpec] = try declaration.memberBlock.members.compactMap { member in
            if let declaration = member.decl.as(VariableDeclSyntax.self) {
                return try declaration.bindings.map { binding in
                    try PrototypeMemberSpec(parsing: binding, of: declaration)
                }
            }
            
            return nil
        }.reduce([], +)
        
        self.init(accessLevelModifiers: declaration.accessLevelModifiers, name: declaration.name.trimmed.text, members: members)
    }
    
    public init(parsing declaration: StructDeclSyntax) throws {
        let members: [PrototypeMemberSpec] = try declaration.memberBlock.members.compactMap { member in
            if let declaration = member.decl.as(VariableDeclSyntax.self) {
                return try declaration.bindings.map { binding in
                    try PrototypeMemberSpec(parsing: binding, of: declaration)
                }
            }
            
            return nil
        }.reduce([], +)
        
        self.init(accessLevelModifiers: declaration.accessLevelModifiers, name: declaration.name.trimmed.text, members: members)
    }
}
