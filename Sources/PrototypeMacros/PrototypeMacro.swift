import SwiftSyntax
import SwiftSyntaxMacros

/// The peer macro implementation of the `@Prototype` macro.
public struct PrototypeMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard isSupportedPeerDeclaration(declaration) else {
            throw PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration)
        }
        
        let arguments = try PrototypeMacroArguments(from: node)
        let spec = try PrototypeSpec(parsing: declaration)

        return try arguments.kinds.map { kind in
            switch kind {
            case .form:
                try buildFormSyntax(spec: spec, arguments: arguments)

            case .settings:
                try buildSettingsSyntax(spec: spec, arguments: arguments)

            case .view:
                try buildViewSyntax(spec: spec, arguments: arguments)
            }
        }
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

// Form building support

extension PrototypeMacro {
    private static func buildFormSyntax(spec: PrototypeSpec, arguments: PrototypeMacroArguments) throws -> DeclSyntax {
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

        let modelAttribute = spec.kind == .binding ? "@Binding" : "@ObservedObject"
        let modelParameter = spec.kind == .binding ? "Binding<\(spec.name)\(spec.genericParameters)>": "\(spec.name)"
        let modelAssignment = spec.kind == .binding ? "self._model = model" : "self.model = model"

        return
            """
            \(raw: spec.accessLevelModifiers.structDeclAccessLevelModifiers) struct \(raw: spec.name)Form\(raw: spec.genericParametersClause): View \(raw: spec.genericWhereClause){
            \(raw: modelAttribute) public var model: \(raw: spec.name)\(raw: spec.genericParameters)
            private let footer: AnyView?
            private let numberFormatter: NumberFormatter
            
            public init(model: \(raw: modelParameter), numberFormatter: NumberFormatter = .init()) {
                \(raw: modelAssignment)
                self.footer = nil
                self.numberFormatter = numberFormatter
            }
            
            public init<Footer>(model: \(raw: modelParameter), numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
                \(raw: modelAssignment)
                self.footer = AnyView(erasing: footer())
                self.numberFormatter = numberFormatter
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
    }

    private static func buildMemberSpecFormSyntax(
        arguments: PrototypeMacroArguments,
        keyPrefix: String,
        spec: PrototypeMemberSpec
    ) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []
        let key = "\"\(keyPrefix).\(spec.name)\""
        let labelKey = "\"\(keyPrefix).\(spec.name).label\""
        let binding = spec.attributes.contains(.modifiable) ? "$model.\(spec.name)" : ".constant(model.\(spec.name))"

        if arguments.style == .labeled {
            result.append("LabeledContent(\(labelKey)) {")
        }

        switch spec.type.name {
        case "Bool":
            result.append("Toggle(\(key), isOn: \(binding))")

        case "String":
            if spec.attributes.contains(.secure) {
                result.append("SecureField(\(key), text: \(binding))")
            } else {
                result.append("TextField(\(key), text: \(binding))")
            }

        case "Date":
            result.append("DatePicker(\(key), selection: \(binding))")

        default:
            if spec.type.isNumeric {
                if let formatExpression = spec.formatExpression {
                    result.append("TextField(\(key), value: \(binding), format: \(formatExpression))")
                } else {
                    result.append("TextField(\(key), value: \(binding), formatter: numberFormatter)")
                }
            } else {
                result.append("\(spec.type.name)Form(model: \(binding))")
            }
        }

        if arguments.style == .labeled {
            result.append("}")
        }

        return result.joined(separator: "\n")
    }
}

// Settings building support

extension PrototypeMacro {
    private static func buildSettingsSyntax(spec: PrototypeSpec, arguments: PrototypeMacroArguments) throws -> DeclSyntax {
        let members = spec.members.filter { member in member.attributes.contains(.visible) }
        var isInSection = false
        var properties: [String] = []
        var body: [String] = []

        members.forEach { member in
            let key = "\(spec.name).\(member.name)"
            let defaultInitializer = member.type.isOptional ? "" : "= .init()"
            let initializer = member.initializer?.description ?? defaultInitializer
            let tail = member.type.isOptional ? "?" : ""
            properties.append("@AppStorage(\"\(key)\") private var \(member.name): \(member.type.name)\(tail) \(initializer)")
        }

        members.forEach { member in
            guard member.type.isOptional else { return }

            properties.append(
                    """
                    private var \(member.name)Binding: Binding<\(member.type.name)> {
                        Binding(
                            get: { \(member.name) ?? \(member.type.defaultValue) },
                            set: { \(member.name) = $0 }
                        )
                    }
                    """
            )
        }

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

            body.append(try buildMemberSpecSettingsSyntax(arguments: arguments, keyPrefix: "\(spec.name)SettingsView", spec: member))
        }

        if isInSection {
            body.append("}")
        }

        return
            """
            \(raw: spec.accessLevelModifiers.structDeclAccessLevelModifiers) struct \(raw: spec.name)SettingsView\(raw: spec.genericParametersClause): View \(raw: spec.genericWhereClause){
            \(raw: properties.joined(separator: "\n"))
            private let footer: AnyView?
            private let numberFormatter: NumberFormatter
            
            public init<Footer>(numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
                self.footer = AnyView(erasing: footer())
                self.numberFormatter = numberFormatter
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
    }

    private static func buildMemberSpecSettingsSyntax(
        arguments: PrototypeMacroArguments,
        keyPrefix: String,
        spec: PrototypeMemberSpec
    ) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []

        let key = "\"\(keyPrefix).\(spec.name)\""
        let labelKey = "\"\(keyPrefix).\(spec.name).label\""
        var binding = spec.attributes.contains(.modifiable) ? "$\(spec.name)" : ".constant(\(spec.name))"

        if spec.type.isOptional {
            if spec.attributes.contains(.modifiable) {
                binding = "\(spec.name)Binding"
            } else {
                binding = ".constant(\(spec.name) ?? \(spec.type.defaultValue)"
            }
        }

        if arguments.style == .labeled {
            result.append("LabeledContent(\(labelKey)) {")
        }

        switch spec.type.name {
        case "Bool":
            result.append("Toggle(\(key), isOn: \(binding))")

        case "String":
            if spec.attributes.contains(.secure) {
                result.append("SecureField(\(key), text: \(binding))")
            } else {
                result.append("TextField(\(key), text: \(binding))")
            }

        case "Date":
            result.append("DatePicker(\(key), selection: \(binding))")

        default:
            if spec.type.isNumeric {
                if let formatExpression = spec.formatExpression {
                    result.append("TextField(\(key), value: \(binding), format: \(formatExpression))")
                } else {
                    result.append("TextField(\(key), value: \(binding), formatter: numberFormatter)")
                }
            } else {
                result.append("\(spec.type.name)Form(model: \(binding))")
            }
        }

        if arguments.style == .labeled {
            result.append("}")
        }

        return result.joined(separator: "\n")
    }
}

// View building support

extension PrototypeMacro {
    private static func buildViewSyntax(spec: PrototypeSpec, arguments: PrototypeMacroArguments) throws -> DeclSyntax {
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
                    body.append("GroupBox(\"\(spec.name)View.\(sectionTitle)\") {")
                } else {
                    body.append("GroupBox {")
                }
            }

            body.append(try buildMemberSpecViewSyntax(arguments: arguments, keyPrefix: "\(spec.name)View", spec: member))
        }

        if isInSection {
            body.append("}")
        }

        if body.isEmpty {
            body.append("EmptyView()")
        }

        return
                """
                \(raw: spec.accessLevelModifiers.structDeclAccessLevelModifiers) struct \(raw: spec.name)View\(raw: spec.genericParametersClause): View \(raw: spec.genericWhereClause){
                public let model: \(raw: spec.name)\(raw: spec.genericParameters)
                
                public init(model: \(raw: spec.name)\(raw: spec.genericParameters)) {
                    self.model = model
                }
                
                public var body: some View {
                    \(raw: body.joined(separator: "\n"))
                }
                }
                """
    }

    private static func buildMemberSpecViewSyntax(
        arguments: PrototypeMacroArguments,
        keyPrefix: String,
        spec: PrototypeMemberSpec
    ) throws -> String {
        guard spec.attributes.contains(.visible) else { return "" }

        var result: [String] = []

        let key = "\"\(keyPrefix).\(spec.name)\""
        let labelKey = "\"\(keyPrefix).\(spec.name).label\""

        if arguments.style == .labeled {
            result.append("LabeledContent(\(labelKey)) {")
        }
        
        if spec.type.name == "Bool" {
            result.append(
            """
            LabeledContent(\(key)) {
                Text(model.\(spec.name).description)
            }
            """
            )
        } else if spec.type.name == "String" {
            let formatArgument = spec.formatExpression.flatMap { expression in
                ", format: \(expression)"
            } ?? ""

            if spec.attributes.contains(.secure) {
                result.append("LabeledContent(\(key), value: \"********\"\(formatArgument))")
            } else {
                result.append("LabeledContent(\(key), value: model.\(spec.name)\(formatArgument))")
            }
        } else if spec.type.name == "Date" {
            if let formatExpression = spec.formatExpression {
                result.append("LabeledContent(\(key), value: model.\(spec.name), format: \(formatExpression))")
            } else {
                result.append("LabeledContent(\(key), value: model.\(spec.name), format: .dateTime)")
            }
        } else if spec.type.isNumeric {
            if let formatExpression = spec.formatExpression {
                result.append("LabeledContent(\(key), value: model.\(spec.name), format: \(formatExpression))")
            } else {
                result.append("LabeledContent(\(key), value: model.\(spec.name), format: .number)")
            }
        } else {
            result.append("\(spec.type.name)View(model: model.\(spec.name))")
        }
        
        if arguments.style == .labeled {
            result.append("}")
        }
        
        return result.joined(separator: "\n")
    }
}
