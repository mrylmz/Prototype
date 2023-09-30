# Prototype (WIP)

Prototype is a **work-in-progress** project that generates SwiftUI Forms and Views for data structures and classes. It's designed to complement SwiftData Models seamlessly.

## Overview

SwiftUI has transformed UI development in Swift, but rapid prototyping by creating views for data models still involves some boilerplate work to be coded. Prototype aims to eliminate this boilerplate by providing a convenient macro to auto-generate SwiftUI code for your data.

## Key Features

- **Rapid prototyping**: Prototype offers a simple macro for effortlessly generating SwiftUI views from your data structures and classes.

- **SwiftData Models Integration**: Prototype works seamlessly with SwiftData Models, making it easy to create SwiftUI representations for your data.

- **Customization**: While Prototype streamlines the process, you can still customize the generated SwiftUI code to match your design needs.

## Example

Here's a quick example of Prototype in action:

Source:
```swift
@Prototype(style: .labeled, kinds: .form, .view)
struct Author {
    let name: String
}
```
Macro Expansion:
```swift
struct AuthorView: View {
    public let model: Author

    public init(model: Author) {
        self.model = model
    }

    public var body: some View {
        LabeledContent("AuthorView.name.label") {
            LabeledContent("AuthorView.name", value: model.name)
        }
    }
}

struct AuthorForm: View {
    @Binding public var model: Author
    private let footer: AnyView?
    private let numberFormatter: NumberFormatter

    public init(model: Binding<Author>, numberFormatter: NumberFormatter = .init()) {
        self._model = model
        self.footer = nil
        self.numberFormatter = numberFormatter
    }

    public init<Footer>(model: Binding<Author>, numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
        self._model = model
        self.footer = AnyView(erasing: footer())
        self.numberFormatter = numberFormatter
    }

    public var body: some View {
        Form {
            LabeledContent("AuthorForm.name.label") {
                TextField("AuthorForm.name", text: .constant(model.name))
            }

            if let footer {
                footer
            }
        }
    }
}
```

Source:
```swift
@Prototype(style: .inline, kinds: .form, .view)
struct Article {
    var title: String
    var content: String
    @Secure var password: String
    
    @Section("metadata")
    var isPublished: Bool
    let views: Int
    let author: Author
}
```
Macro Expansion:
```swift
struct ArticleForm: View {
    @Binding public var model: Article
    private let footer: AnyView?
    private let numberFormatter: NumberFormatter

    public init(model: Binding<Article>, numberFormatter: NumberFormatter = .init()) {
        self._model = model
        self.footer = nil
        self.numberFormatter = numberFormatter
    }

    public init<Footer>(model: Binding<Article>, numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
        self._model = model
        self.footer = AnyView(erasing: footer())
        self.numberFormatter = numberFormatter
    }

    public var body: some View {
        Form {
            TextField("ArticleForm.title", text: $model.title)
            TextField("ArticleForm.content", text: $model.content)
            SecureField("ArticleForm.password", text: $model.password)
            Section(header: Text("ArticleForm.metadata")) {
                Toggle("ArticleForm.isPublished", isOn: $model.isPublished)
                TextField("ArticleForm.views", value: .constant(model.views), formatter: numberFormatter)
                AuthorForm(model: .constant(model.author))
            }

            if let footer {
                footer
            }
        }
    }
}

struct ArticleView: View {
    public let model: Article

    public init(model: Article) {
        self.model = model
    }

    public var body: some View {
        LabeledContent("ArticleView.title", value: model.title)
        LabeledContent("ArticleView.content", value: model.content)
        LabeledContent("ArticleView.password", value: "********")
        GroupBox("ArticleView.metadata") {
            LabeledContent("ArticleView.isPublished") {
                Text(model.isPublished.description)
            }
            LabeledContent("ArticleView.views", value: model.views, format: .number)
            AuthorView(model: model.author)
        }
    }
}
```

Source:
```swift
@Prototype(style: .inline, kinds: .settings)
struct General {
    var boolValue: Bool = false
    var intValue: Int = 0
    var doubleValue: Double = 0
    var stringValue: String = ""
    var optionalBoolValue: Bool?
    var optionalIntValue: Int?
    var optionalDoubleValue: Double?
    var optionalStringValue: String?
}

```
Macro Expansion:
```swift
struct GeneralSettingsView: View {
    @AppStorage("General.boolValue") private var boolValue: Bool = false
    @AppStorage("General.intValue") private var intValue: Int = 0
    @AppStorage("General.doubleValue") private var doubleValue: Double = 0
    @AppStorage("General.stringValue") private var stringValue: String = ""
    @AppStorage("General.optionalBoolValue") private var optionalBoolValue: Bool?
    @AppStorage("General.optionalIntValue") private var optionalIntValue: Int?
    @AppStorage("General.optionalDoubleValue") private var optionalDoubleValue: Double?
    @AppStorage("General.optionalStringValue") private var optionalStringValue: String?
    private var optionalBoolValueBinding: Binding<Bool> {
        Binding(
            get: {
                optionalBoolValue ?? false
            },
            set: {
                optionalBoolValue = $0
            }
        )
    }
    private var optionalIntValueBinding: Binding<Int> {
        Binding(
            get: {
                optionalIntValue ?? 0
            },
            set: {
                optionalIntValue = $0
            }
        )
    }
    private var optionalDoubleValueBinding: Binding<Double> {
        Binding(
            get: {
                optionalDoubleValue ?? 0
            },
            set: {
                optionalDoubleValue = $0
            }
        )
    }
    private var optionalStringValueBinding: Binding<String> {
        Binding(
            get: {
                optionalStringValue ?? ""
            },
            set: {
                optionalStringValue = $0
            }
        )
    }
    private let footer: AnyView?
    private let numberFormatter: NumberFormatter

    public init<Footer>(numberFormatter: NumberFormatter = .init(), @ViewBuilder footer: () -> Footer) where Footer: View {
        self.footer = AnyView(erasing: footer())
        self.numberFormatter = numberFormatter
    }

    public var body: some View {
        Form {
            Toggle("GeneralSettingsView.boolValue", isOn: $boolValue)
            TextField("GeneralSettingsView.intValue", value: $intValue, formatter: numberFormatter)
            TextField("GeneralSettingsView.doubleValue", value: $doubleValue, formatter: numberFormatter)
            TextField("GeneralSettingsView.stringValue", text: $stringValue)
            Toggle("GeneralSettingsView.optionalBoolValue", isOn: optionalBoolValueBinding)
            TextField("GeneralSettingsView.optionalIntValue", value: optionalIntValueBinding, formatter: numberFormatter)
            TextField("GeneralSettingsView.optionalDoubleValue", value: optionalDoubleValueBinding, formatter: numberFormatter)
            TextField("GeneralSettingsView.optionalStringValue", text: optionalStringValueBinding)

            if let footer {
                footer
            }
        }
    }
}
```

## License

Prototype is under the MIT License. Refer to [LICENSE](LICENSE) for details.
