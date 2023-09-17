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
        guard isSupportedPeerDeclaration(declaration) else { throw PrototypeMacroError.unsupportedPeerDeclaration }
        
        let prototypeKinds = try parsePrototypeKinds(from: node)
        let hasForm = prototypeKinds.contains(prototypeKindIdentifierForm)
        let hasView = prototypeKinds.contains(prototypeKindIdentifierView)
        let spec = try PrototypeSpec(parsing: declaration)
        var result: [DeclSyntax] = []

        if hasForm {
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
                
                body.append(try buildMemberSpecFormSyntax(keyPrefix: "\(spec.name)Form", spec: member))
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
        }
        
        if hasView {
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
    private static func buildMemberSpecFormSyntax(keyPrefix: String, spec: PrototypeMemberSpec) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []

        #warning("Add macro support for text field validators")
        #warning("Add text field support for float and other numeric primitive types with validators")
        #warning("Only make numerics to Stepper by using an attribute like @Secure")

        let key = "\"\(keyPrefix).\(spec.name)\""
        let binding = spec.attributes.contains(.modifiable) ? "$model.\(spec.name)" : ".constant(model.\(spec.name))"

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
            throw PrototypeMacroError.unsupportedTypeError(type: spec.type, member: spec.name)
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
            throw PrototypeMacroError.unsupportedTypeError(type: spec.type, member: spec.name)
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
            throw PrototypeMacroError.missingPrototypeKindArgument
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
                throw PrototypeMacroError.invalidPrototypeKindArgument
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
