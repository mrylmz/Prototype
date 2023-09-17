import SwiftSyntax

extension DeclSyntaxProtocol {
    /// Returns the associated attributes of the declaration or defaults to an empty list if not present.
    public var attributeList: AttributeListSyntax {
        if let decl = self.as(AccessorDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(ActorDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(AssociatedTypeDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(ClassDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(DeinitializerDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(EditorPlaceholderDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(EnumCaseDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(EnumDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(ExtensionDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(FunctionDeclSyntax.self) {
            return decl.attributes
        }
        
        if let _ = self.as(IfConfigDeclSyntax.self) {
            return AttributeListSyntax()
        }
        
        if let decl = self.as(ImportDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(InitializerDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(MacroDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(MacroExpansionDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(MissingDeclSyntax.self) {
            return decl.attributes
        }
        
        if let _ = self.as(OperatorDeclSyntax.self) {
            return AttributeListSyntax()
        }
        
        if let _ = self.as(PoundSourceLocationSyntax.self) {
            return AttributeListSyntax()
        }
        
        if let decl = self.as(PrecedenceGroupDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(ProtocolDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(StructDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(SubscriptDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(TypeAliasDeclSyntax.self) {
            return decl.attributes
        }
        
        if let decl = self.as(VariableDeclSyntax.self) {
            return decl.attributes
        }
        
        return AttributeListSyntax()
    }
    
    public func hasAttribute(named name: String) -> Bool {
        attributeList.contains { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.trimmed.text == name
        }
    }
    
    public func attribute(named name: String) -> AttributeSyntax? {
        attributeList
            .compactMap { attribute in attribute.as(AttributeSyntax.self) }
            .first { attribute in attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.trimmed.text == name }
    }
}
