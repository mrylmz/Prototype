import Foundation
import SwiftSyntax

extension AttributeSyntax {
    public func hasArgument(labeled label: String) -> Bool {
        guard let arguments = arguments?.as(LabeledExprListSyntax.self) else { return false }
        
        return arguments.contains { $0.label?.tokenKind == .identifier(label) }
    }
    
    public func argument(labeled label: String) -> LabeledExprSyntax? {
        arguments?
            .as(LabeledExprListSyntax.self)?
            .first { $0.label?.tokenKind == .identifier(label) }
    }
    
    public func arguments(after argument: LabeledExprSyntax) -> [LabeledExprSyntax] {
        guard 
            let arguments = arguments?.as(LabeledExprListSyntax.self),
            let argumentIndex = arguments.firstIndex(of: argument)
        else { return [] }
        
        return arguments.suffix(from: arguments.index(after: argumentIndex)).compactMap { $0.as(LabeledExprSyntax.self) }
    }
}
