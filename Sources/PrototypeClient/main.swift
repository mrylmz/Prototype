import Prototype
import SwiftUI

@Prototype(.form)
struct Article {
    var title: String
    var content: String
    var author: String
    var isPublished: Bool
    let views: Int
}
