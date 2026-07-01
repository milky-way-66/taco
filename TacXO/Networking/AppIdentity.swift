import ComunicationCore
import Foundation
import Security

struct AppIdentity: IdentityPort {
    private static let keychainKey = "com.xo.game.participantID"

    var currentParticipantID: ParticipantID {
        get async {
            ParticipantID(Self.loadOrCreateID())
        }
    }

    private static func loadOrCreateID() -> String {
        if let existing = readKeychain() { return existing }
        let newID = UUID().uuidString
        saveKeychain(newID)
        return newID
    }

    private static func readKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }

    private static func saveKeychain(_ value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
