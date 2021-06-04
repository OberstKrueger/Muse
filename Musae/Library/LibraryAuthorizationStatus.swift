/// Authorization status of the user's music library.
public enum LibraryAuthorizationStatus {
    /// Library access is authorized.
    case authorized
    /// Library access is denied.
    case denied
    /// Library access has not been asked for yet.
    case notAsked
    /// Library access is unknown; initialization state.
    case unknown
}
