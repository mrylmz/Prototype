import Foundation
import SwiftSyntax

#warning("Add documentation")
public struct AccessLevelModifiers: OptionSet {
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public static let none: Self = .init([])
    public static let `private`: Self = .init(rawValue: 1 << 0)
    public static let privateSet: Self = .init(rawValue: 1 << 1)
    public static let `fileprivate`: Self = .init(rawValue: 1 << 2)
    public static let fileprivateSet: Self = .init(rawValue: 1 << 3)
    public static let `internal`: Self = .init(rawValue: 1 << 4)
    public static let internalSet: Self = .init(rawValue: 1 << 5)
    public static let `public`: Self = .init(rawValue: 1 << 6)
    public static let publicSet: Self = .init(rawValue: 1 << 7)
    public static let `open`: Self = .init(rawValue: 1 << 8)
    public static let openSet: Self = .init(rawValue: 1 << 9)
}

extension AccessLevelModifiers: CustomStringConvertible {
    public var description: String {
        var modifierDescriptions: [String] = []
        
        if contains(.private) {
            modifierDescriptions.append("private")
        }
        
        if contains(.fileprivate) {
            modifierDescriptions.append("fileprivate")
        }
        
        if contains(.internal) {
            modifierDescriptions.append("internal")
        }
        
        if contains(.public) {
            modifierDescriptions.append("public")
        }
        
        if contains(.open) {
            modifierDescriptions.append("open")
        }
        
        if contains(.privateSet) {
            modifierDescriptions.append("private(set)")
        }
        
        if contains(.fileprivateSet) {
            modifierDescriptions.append("fileprivate(set)")
        }
        
        if contains(.internalSet) {
            modifierDescriptions.append("internal(set)")
        }
        
        if contains(.publicSet) {
            modifierDescriptions.append("public(set)")
        }
        
        if contains(.openSet) {
            modifierDescriptions.append("open(set)")
        }
        
        return modifierDescriptions.joined(separator: " ")
    }
}

extension AccessLevelModifiers {
    /// Migrates access level modifiers to a new collection supporting `struct` declarations.
    public var structDeclAccessLevelModifiers: AccessLevelModifiers {
        if contains(.private) {
            return .private
        }
        
        if contains(.fileprivate) {
            return .fileprivate
        }
        
        if contains(.internal) {
            return .internal
        }
        
        if contains(.public) || contains(.open) {
            return .public
        }
     
        return .none
    }
}

extension DeclSyntaxProtocol {
    /// Returns `modifiers` member  of the `declaration` or an empty initialized `DeclModifierListSyntax` if `declaration` syntax doesn't support modifiers.
    public var modifiers: DeclModifierListSyntax {
        if let decl = self.as(ActorDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(AssociatedTypeDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(ClassDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(DeinitializerDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(EditorPlaceholderDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(EnumCaseDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(EnumDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(ExtensionDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(FunctionDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(IfConfigDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(ImportDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(InitializerDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(MacroDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(MacroExpansionDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(MissingDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(OperatorDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(PoundSourceLocationSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(PrecedenceGroupDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(ProtocolDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(StructDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(SubscriptDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(TypeAliasDeclSyntax.self) {
            return decl.modifiers
        }
        
        if let decl = self.as(VariableDeclSyntax.self) {
            return decl.modifiers
        }
        
        return DeclModifierListSyntax()
    }
    
    /// Returns the access level modifiers of the `declaration`.
    public var accessLevelModifiers: AccessLevelModifiers {
        AccessLevelModifiers(modifiers.map { modifier in
            let isSetModifier = modifier.detail?.detail.tokenKind == .identifier("set")
            
            switch modifier.name.tokenKind {
            case .keyword(.private):
                return isSetModifier ? .privateSet : .private
                
            case .keyword(.fileprivate):
                return isSetModifier ? .fileprivateSet : .fileprivate
                
            case .keyword(.internal):
                return isSetModifier ? .internalSet : .internal
                
            case .keyword(.public):
                return isSetModifier ? .publicSet : .public
                
            case .keyword(.open):
                return isSetModifier ? .openSet : .open
                
            default:
                return .none
            }
        })
    }
}
