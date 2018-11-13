import Vapor
public struct MailgunError: Error, Content {
    public var errors: [MailgunErrorResponse]?
}

public struct MailgunErrorResponse: Content {
    public var message: String?
    public var field: String?
    public var help: String?
}
