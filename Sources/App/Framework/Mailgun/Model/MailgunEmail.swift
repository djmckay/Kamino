import Vapor

public struct MailgunEmail: Content {
    
    /// An array of messages and their metadata. Each object within personalizations can be thought of as an envelope - it defines who should receive an individual message and how that message should be handled.
    public var to: [EmailAddress]?
    
    public var from: EmailAddress?

    public var cc: [EmailAddress]?

    public var bcc: [EmailAddress]?


    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    public var subject: String?
    
    /// An array in which you may specify the content of your email.
    public var text: String?
    public var html: String?

    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?
    
    public init(from: EmailAddress? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                to: [EmailAddress]? = nil,
                text: String? = nil,
                html: String? = nil,
                subject: String? = nil,
                attachments: [EmailAttachment]? = nil) {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.text = text
        self.html = html
        self.subject = subject
        self.attachments = attachments
    }
    
    public enum CodingKeys: String, CodingKey {
        case from
        case to
        case cc
        case bcc
        case text
        case html
        case subject
        case attachments
    }
}
