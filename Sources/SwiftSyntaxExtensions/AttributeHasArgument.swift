import SwiftSyntax

extension AttributeSyntax {
    /// Validates if `AttributeSyntax` is containing an `argument` labeled with `label`.
    ///
    /// - Parameter label: The `label` to check for if it is in the argument list of the `AttributeSyntax`.
    /// - Returns: A `Bool` value indicating if the `AttributeSyntax` contains an argument with the given `label`.
    public func hasArgument(labeled label: String) -> Bool {
        guard let arguments = arguments?.as(LabeledExprListSyntax.self) else { return false }
        
        return arguments.contains { $0.label?.tokenKind == .identifier(label) }
    }
    
    /// Searches for an `argument` labeled with `label` in an `AttributeSyntax`.
    ///
    /// - Parameter label: The `label` to check for if it is in the argument list of the `AttributeSyntax`.
    /// - Returns: The `argument` having the given `label` as label.
    public func argument(labeled label: String) -> LabeledExprSyntax? {
        arguments?
            .as(LabeledExprListSyntax.self)?
            .first { $0.label?.tokenKind == .identifier(label) }
    }
    
    /// Returns a collection of arguments in `AttributeSyntax` which occur after the given member `argument`.
    ///
    /// - Parameter argument: The `argument` after which to slice the `arguments` of the `AttributeSyntax`.
    /// - Returns: The sliced collection of arguments in `AttributeSyntax`.
    public func arguments(after argument: LabeledExprSyntax) -> [LabeledExprSyntax] {
        guard 
            let arguments = arguments?.as(LabeledExprListSyntax.self),
            let argumentIndex = arguments.firstIndex(of: argument)
        else { return [] }
        
        return arguments.suffix(from: arguments.index(after: argumentIndex)).compactMap { $0.as(LabeledExprSyntax.self) }
    }
}
