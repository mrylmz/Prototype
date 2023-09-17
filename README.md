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

```swift
import Prototype
import SwiftUI

@Prototype(.form)
struct Article {
    @Section
    var title: String
    var content: String
    var author: String
    
    @Section("metadata")
    var isPublished: Bool
    let views: Int
}
// Macro expansion:
struct ArticleForm: View {
    @Binding public var model: Article
    private let footer: AnyView?

    public init(model: Binding<Article>) {
        self._model = model
        self.footer = nil
    }

    public init<Footer>(model: Binding<Article>, @ViewBuilder footer: () -> Footer) where Footer: View {
        self._model = model
        self.footer = AnyView(erasing: footer())
    }

    public var body: some View {
        Form {
            Section {
                TextField("ArticleForm.title", text: $model.title)
                TextField("ArticleForm.content", text: $model.content)
                TextField("ArticleForm.author", text: $model.author)
            }
            Section(header: Text("ArticleForm.metadata")) {
                Toggle("ArticleForm.isPublished", isOn: $model.isPublished)
                Stepper("ArticleForm.views", value: .constant(model.views))
            }

            if let footer {
                footer
            }
        }
    }
}
```

## License

Prototype is under the MIT License. Refer to [LICENSE](LICENSE) for details.
