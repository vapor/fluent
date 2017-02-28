/// The naming convetion to use for foreign
/// id keys, table names, etc.
/// ex: snake_case vs. camelCase.
public enum KeyNamingConvention {
    case snake_case
    case camelCase
}

extension String {
    internal func snake_case() -> String {
        let characters = Array(self.characters)

        guard var expanded = characters
            .first
            .flatMap({ String($0) })
            else {
                return ""
        }

        characters.suffix(from: 1).forEach { char in
            if char.isUppercase {
                expanded.append("_")
            }

            expanded.append(char)
        }

        return expanded.lowercased()
    }

    internal func camelCase() -> String {
        return
            String(characters.prefix(1)).lowercased() +
            String(characters.dropFirst())
    }
}

extension Character {
    internal var isUppercase: Bool {
        switch self {
        case "A"..."Z":
            return true
        default:
            return false
        }
    }
}
