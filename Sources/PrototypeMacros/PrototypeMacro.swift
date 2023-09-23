import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxExtensions

public struct PrototypeMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard isSupportedPeerDeclaration(declaration) else {
            throw PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration)
        }
        
        let arguments = try PrototypeArguments(from: node)
        let spec = try PrototypeSpec(parsing: declaration)
        var result: [DeclSyntax] = []

        try arguments.kinds.forEach { kind in
            switch kind {
            case .form:
                let members = spec.members.filter { member in member.attributes.contains(.visible) }
                var isInSection = false
                var body: [String] = []
                
                try members.forEach { member in
                    if member.attributes.contains(.section) {
                        if isInSection {
                            body.append("}")
                        }
                        
                        isInSection = true
                        
                        if let sectionTitle = member.sectionTitle {
                            body.append("Section(header: Text(\"\(spec.name)Form.\(sectionTitle)\")) {")
                        } else {
                            body.append("Section {")
                        }
                    }
                    
                    body.append(try buildMemberSpecFormSyntax(arguments: arguments, keyPrefix: "\(spec.name)Form", spec: member))
                }
                
                if isInSection {
                    body.append("}")
                }
                
                result.append(
                """
                \(raw: spec.accessLevelModifiers.structDeclAccessLevelModifiers) struct \(raw: spec.name)Form: View {
                @Binding public var model: \(raw: spec.name)
                private let footer: AnyView?
                
                public init(model: Binding<\(raw: spec.name)>) {
                    self._model = model
                    self.footer = nil
                }
                
                public init<Footer>(model: Binding<\(raw: spec.name)>, @ViewBuilder footer: () -> Footer) where Footer: View {
                    self._model = model
                    self.footer = AnyView(erasing: footer())
                }

                public var body: some View {
                    Form {
                        \(raw: body.joined(separator: "\n"))
                
                        if let footer {
                            footer
                        }
                    }
                }
                }
                """
                )
                
            case .view:
                var membersBody = try spec.members
                    .filter { member in member.attributes.contains(.visible) }
                    .map { member in try buildMemberSpecViewSyntax(member) }
                    .joined(separator: "\n")
                
                if membersBody.isEmpty {
                    membersBody = "EmptyView()"
                }
                
                result.append(
                """
                \(raw: spec.accessLevelModifiers.structDeclAccessLevelModifiers) struct \(raw: spec.name)View: View {
                public let model: \(raw: spec.name)
                
                public init(model: \(raw: spec.name)) {
                    self.model = model
                }

                public var body: some View {
                    \(raw: membersBody)
                }
                }
                """
                )
            }
        }
        
        return result
    }
}

extension PrototypeMacro {
    private static func isSupportedPeerDeclaration(_ declaration: DeclSyntaxProtocol) -> Bool {
        return (
            declaration.is(ClassDeclSyntax.self) ||
            declaration.is(StructDeclSyntax.self)
        )
    }
}

extension PrototypeMacro {
    private static func buildMemberSpecFormSyntax(
        arguments: PrototypeArguments,
        keyPrefix: String,
        spec: PrototypeMemberSpec
    ) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []

        #warning("Add macro support for text field validators")
        #warning("Add text field support for float and other numeric primitive types with validators")
        #warning("Only make numerics to Stepper by using an attribute like @Secure")

        let key = "\"\(keyPrefix).\(spec.name)\""
        let binding = spec.attributes.contains(.modifiable) ? "$model.\(spec.name)" : ".constant(model.\(spec.name))"

        if arguments.style == .labeled {
            result.append("LabeledContent(\(key)) {")
        }
        
        switch spec.type {
        case "Bool":
            result.append("Toggle(\(key), isOn: \(binding))")

        case "Int":
            result.append("Stepper(\(key), value: \(binding))")

        case "String":
            if spec.attributes.contains(.secure) {
                result.append("SecureField(\(key), text: \(binding))")
            } else {
                result.append("TextField(\(key), text: \(binding))")
            }
            
        case "Date":
            result.append("DatePicker(\(key), selection: \(binding))")

        default:
            result.append("\(spec.type)Form(model: \(binding))")
        }
        
        if arguments.style == .labeled {
            result.append("}")
        }
        
        return result.joined(separator: "\n")
    }
    
    private static func buildMemberSpecViewSyntax(_ spec: PrototypeMemberSpec) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []

        #warning("Rethink usage of views...")

        let value = "\"\\(model.\(spec.name))\""

        switch spec.type {
        case "Bool":
            result.append("Text(\(value))")

        case "Int":
            result.append("Text(\(value))")

        case "String":
            if !spec.attributes.contains(.secure) {
                result.append("Text(\(value))")
            }
            
        default:
            result.append("\(spec.type)View(model: \(value))")
        }
        
        return result.joined(separator: "\n")
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
            throw PrototypeMacrosError.missingPrototypeKindsArgument
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
                throw PrototypeMacrosError.invalidPrototypeKindsArgument
            }
            
            return identifier
        }
        
        let distinctPrototypeKinds = Set(parsedPrototypeKinds)
        
        guard parsedPrototypeKinds.count == distinctPrototypeKinds.count else {
            throw PrototypeMacrosError.duplicatePrototypeKindArgument
        }
        
        return parsedPrototypeKinds
    }
}
