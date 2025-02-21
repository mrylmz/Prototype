import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PrototypeMacros)
import PrototypeMacros

let testMacros: [String: Macro.Type] = [
    "Field": FieldMacro.self,
    "Prototype": PrototypeMacro.self,
]
#endif

final class PrototypeTests: XCTestCase {
    func testProtoptypeMacroSupportsDecimal() throws {
#if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view)
            class MyClass {
                @Format(using: .custom)
                let decimalValue: Decimal
            }
            """,
            expandedSource: """
            class MyClass {
                @Format(using: .custom)
                let decimalValue: Decimal
            }
            
            struct MyClassView: View {
                public let model: MyClass
            
                public init(model: MyClass) {
                    self.model = model
                }
            
                public var body: some View {
                    LabeledContent("MyClassView.decimalValue.label") {
                        LabeledContent("MyClassView.decimalValue", value: model.decimalValue, format: .custom)
                    }
                }
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testPrototypeMacroErrorUnsupportedPeerDeclarationOnEnum() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view)
            enum MyEnum {}
            """,
            expandedSource: """
            enum MyEnum {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorUnsupportedPeerDeclarationOnVariable() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view)
            var myValue: Int = 0
            """,
            expandedSource: """
            var myValue: Int = 0
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.macro("Prototype", canOnlyBeAttachedTo: .classOrStructDeclaration).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorInvalidPrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .unknown)
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.invalid(argument: "kinds: .unknown", givenForArgument: .kinds, ofMacro: .prototype).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testPrototypeMacroErrorMissingPrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype()
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.missing(argument: .kinds, ofMacro: .prototype).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorDuplicatePrototypeKindArgument() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .view, .form, .form, .view)
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.duplicate(argument: "form, view", givenForArgument: .kinds, ofMacro: .prototype).debugDescription,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorMissingMemberPatternTypeAnnotation() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(kinds: .form)
            struct MyStruct {
                @Environment(\\.accessibilityEnabled) var accessibilityEnabled
            }
            """,
            expandedSource: """
            import SwiftUI
            struct MyStruct {
                @Environment(\\.accessibilityEnabled) var accessibilityEnabled
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.missingSyntax(.typeAnnotation, forMember: "accessibilityEnabled", ofMacro: .prototype).debugDescription,
                    line: 3,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorUnsupportedMemberPatternBinding() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(kinds: .form)
            class MyClass {
                var callable: () -> Void
            }
            """,
            expandedSource: """
            import SwiftUI
            class MyClass {
                var callable: () -> Void
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.unsupportedType("() -> Void", forMember: "callable", ofMacro: .prototype).debugDescription,
                    line: 3,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroErrorUnsupportedPatternBinding() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(kinds: .form)
            class MyClass {
                var (x, y): (Int, Int)
            }
            """,
            expandedSource: """
            import SwiftUI
            class MyClass {
                var (x, y): (Int, Int)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: PrototypeMacrosError.unsupportedPatternBinding("(x, y)", givenInMemberListOfMacro: .prototype).debugDescription,
                    line: 3,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testPrototypeMacroWithSettingsKind() throws {
        #if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            @Prototype(style: .inline, kinds: .settings)
            struct General {
                var showPreview: Bool = false
                var text: String = "Hello World!"
                var fontSize: Double = 12.0
            }
            """,
            expandedSource: """
            import SwiftUI
            struct General {
                var showPreview: Bool = false
                var text: String = "Hello World!"
                var fontSize: Double = 12.0
            }

            struct GeneralSettingsView: View {
                @AppStorage("General.showPreview") private var showPreview: Bool = false
                @AppStorage("General.text") private var text: String = "Hello World!"
                @AppStorage("General.fontSize") private var fontSize: Double = 12.0
                private let footer: AnyView?
                private let numberFormatter: NumberFormatter

                public init<Footer>(numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
                    self.footer = AnyView(erasing: footer())
                    self.numberFormatter = numberFormatter
                }

                public var body: some View {
                    Form {
                        Toggle("GeneralSettingsView.showPreview", isOn: $showPreview)
                        TextField("GeneralSettingsView.text", text: $text)
                        TextField("GeneralSettingsView.fontSize", value: $fontSize, formatter: numberFormatter)

                        if let footer {
                            footer
                        }
                    }
                }
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testProtoytypeFormWithObservableObject() {
#if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .form)
            class Sample: ObservableObject {
                var value: Int
            }
            """,
            expandedSource: """
            class Sample: ObservableObject {
                var value: Int
            }
            
            struct SampleForm: View {
                @ObservedObject public var model: Sample
                private let footer: AnyView?
                private let numberFormatter: NumberFormatter
            
                public init(model: Sample, numberFormatter: NumberFormatter = .init()) {
                    self.model = model
                    self.footer = nil
                    self.numberFormatter = numberFormatter
                }
            
                public init<Footer>(model: Sample, numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
                    self.model = model
                    self.footer = AnyView(erasing: footer())
                    self.numberFormatter = numberFormatter
                }
            
                public var body: some View {
                    Form {
                        LabeledContent("SampleForm.value.label") {
                            TextField("SampleForm.value", value: $model.value, formatter: numberFormatter)
                        }
            
                        if let footer {
                            footer
                        }
                    }
                }
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testProtoytypeFormWithClass() {
#if canImport(PrototypeMacros)
        assertMacroExpansion(
            """
            @Prototype(kinds: .form)
            class Sample {
                var value: Int
            }
            """,
            expandedSource: """
            class Sample {
                var value: Int
            }
            
            struct SampleForm: View {
                @Binding public var model: Sample
                private let footer: AnyView?
                private let numberFormatter: NumberFormatter
            
                public init(model: Binding<Sample>, numberFormatter: NumberFormatter = .init()) {
                    self._model = model
                    self.footer = nil
                    self.numberFormatter = numberFormatter
                }
            
                public init<Footer>(model: Binding<Sample>, numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
                    self._model = model
                    self.footer = AnyView(erasing: footer())
                    self.numberFormatter = numberFormatter
                }
            
                public var body: some View {
                    Form {
                        LabeledContent("SampleForm.value.label") {
                            TextField("SampleForm.value", value: $model.value, formatter: numberFormatter)
                        }
            
                        if let footer {
                            footer
                        }
                    }
                }
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
