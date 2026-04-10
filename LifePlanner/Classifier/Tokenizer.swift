import Foundation

enum Tokenizer {
    private static let stopWords: Set<String> = [
        "a", "an", "and", "at", "for", "in", "is", "my", "of", "on", "the", "to", "with"
    ]

    static func tokens(from text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { token in
                token.count > 1 && !stopWords.contains(token)
            }
    }
}
