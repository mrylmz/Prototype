import SwiftSyntax
import SwiftSyntaxExtensions
import SwiftUI

public struct PrototypeSpec {
    public enum Kind {
        case binding
        case observable
    }

    public let accessLevelModifiers: AccessLevelModifiers
    public let name: String
    public let members: [PrototypeMemberSpec]
    public let kind: Kind
    public let genericParametersClause: String
    public let genericParameters: String
    public let genericWhereClause: String

    public init(
        accessLevelModifiers: AccessLevelModifiers,
        name: String,
        members: [PrototypeMemberSpec],
        kind: Kind = .binding,
        genericParametersClause: String,
        genericParameters: String,
        genericWhereClause: String
    ) {
        self.accessLevelModifiers = accessLevelModifiers
        self.name = name
        self.members = members
        self.kind = kind
        self.genericParametersClause = genericParametersClause
        self.genericParameters = genericParameters
        self.genericWhereClause = genericWhereClause
    }

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

        let kind = declaration.inheritanceClause?.inheritedTypes.contains {
            $0.type.trimmedDescription == "ObservableObject"
        } == true ? Kind.observable : .binding

        self.init(
            accessLevelModifiers: declaration.accessLevelModifiers,
            name: declaration.name.trimmed.text,
            members: members,
            kind: kind,
            genericParametersClause: declaration.genericParameterClause?.trimmedDescription ?? "",
            genericParameters: declaration.genericParameterClause?.names ?? "",
            genericWhereClause: declaration.genericWhereClause?.trimmedDescription ?? ""
        )
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
        
        self.init(
            accessLevelModifiers: declaration.accessLevelModifiers,
            name: declaration.name.trimmed.text,
            members: members,
            genericParametersClause: declaration.genericParameterClause?.trimmedDescription ?? "",
            genericParameters: declaration.genericParameterClause?.names ?? "",
            genericWhereClause: declaration.genericWhereClause?.trimmedDescription ?? ""
        )
    }
}

extension GenericParameterClauseSyntax {
    var names: String {
        return "<" + parameters.map {
            $0.name.trimmedDescription
        }
        .joined(separator: ", ") + ">"
    }
}
