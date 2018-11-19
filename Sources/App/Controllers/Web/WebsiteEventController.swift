//
//  WebsiteEventController.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Vapor
import Leaf
import Fluent
import Authentication
import FluentMySQL

struct WebsiteEventController: RouteCollection {
    static let dateFormatter: DateFormatter = {
        let instance = DateFormatter()
        // setup code
        instance.dateFormat = "MM/dd/yyyy"
        return instance
    }()
    
    func boot(router: Router) throws {
        let eventRoutes = router.grouped("events")
        let authSessionRoutes = eventRoutes.grouped(User.authSessionsMiddleware())
//        authSessionRoutes.get("events", "create", use: createEventHandler)
//        authSessionRoutes.get("events", String.parameter, use: createEventHandler)
//        authSessionRoutes.get("events", use: allEventHandler)
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("create", use: createEventHandler)
        protectedRoutes.post(CreateEventData.self, at: "create", use: createEventPostHandler)
        protectedRoutes.post(CreateEventData.self, at: Event.parameter, "edit", use: editEventPostHandler)
        protectedRoutes.post(Event.parameter, "delete", use: deleteEventPostHandler)
        protectedRoutes.get(Event.parameter, "edit", use: getEventHandler)
        protectedRoutes.get("user", use: allUserEventsHandler)
        protectedRoutes.get(use: allEventHandler)
        protectedRoutes.get("users", User.parameter, use: teamUserEventsHandler)
        protectedRoutes.get(Event.parameter, use: eventHandler)
        protectedRoutes.get(Event.parameter, "registrationForm", use: getEventRegistrationForm)
        protectedRoutes.post(Event.parameter, "registrationForm", use: postEventRegistrationForm)

    }
    
    func getEventHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Event.self)
            .flatMap(to: View.self) { event in
                
                let start = WebsiteEventController.dateFormatter.string(from: event.startDate)
                let end = WebsiteEventController.dateFormatter.string(from: event.endDate)
                
                let data = CreateEventData(name: event.name, password: event.password, confirmPassword: event.password, message: "", startDate: start, endDate: end, logo: nil, description: nil, locationName: event.locationName, locationAddress: event.locationAddress, locationAddressLine2: event.locationAddressLine2, locationCity: event.locationCity, locationCountry: event.locationCountry, locationState: event.locationState, locationPostalCode: event.locationPostalCode, logoFilename: event.logoFilename)
                let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
                var context = CreateEventContext(csrfToken: token, userLoggedIn: true, editing: true, data: data)
                context.title = "Edit Event"
                try req.session()["CSRF_TOKEN"] = token
                return try req.view().render("createEvent", context)
        }
    }
    
    
    
    func createEventHandler(_ req: Request) throws -> Future<View> {
        let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
        let context = CreateEventContext(csrfToken: token, userLoggedIn: true, editing: false, data: nil)
        try req.session()["CSRF_TOKEN"] = token
        return try req.view().render("createEvent", context)
    }
    
    func deleteEventPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(Event.self).flatMap(to: Response.self, { (event)  in
            let directory = DirectoryConfig.detect()
            let workingDirectory = directory.workDir
            let name = event.uuid.uuidString + ".png"
            let imageFolder = "/images"
            let deleteURL = URL(fileURLWithPath: workingDirectory).appendingPathComponent("/Private"+imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
            do {
                try FileManager.default.removeItem(at: deleteURL)
            } catch {
                print("Error creating folder in documents dir: \(error)")
                
            }
            return event.delete(on: req)
                .transform(to: req.redirect(to: "/events"))
        })
            
        
    }
    
    func createEventPostHandler(_ req: Request, data: CreateEventData) throws -> Future<View> {
        //return try req.view().render("createEvent", data)
        let startDate = WebsiteEventController.dateFormatter.date(from: data.startDate) ?? Date()
        let endDate = WebsiteEventController.dateFormatter.date(from: data.endDate) ?? Date()
        let user = try req.requireAuthenticated(User.self)
        let event = Event(name: data.name, password: data.password, startDate: startDate, endDate: endDate, user: user)
        return try editOrCreateEventHandler(req, data, event, false)
        

    }
    
    fileprivate func editOrCreateEventHandler(_ req: Request, _ data: CreateEventData, _ event: Event, _ isEditing: Bool) throws -> EventLoopFuture<View> {
        do {
            
            try data.validate()
        } catch {
            let data = CreateEventData(name: data.name, password: data.password, confirmPassword: data.confirmPassword, message: "", startDate: data.startDate, endDate: data.endDate, logo: nil, description: nil, locationName: data.locationName, locationAddress: data.locationAddress, locationAddressLine2: data.locationAddressLine2, locationCity: data.locationCity, locationCountry: data.locationCountry, locationState: data.locationState, locationPostalCode: data.locationPostalCode, logoFilename: event.logoFilename)
            let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
            var context = CreateEventContext(csrfToken: token, userLoggedIn: true, editing: true, data: data)
            try req.session()["CSRF_TOKEN"] = token
            if let error = error as? KaminoValidationError {
                context.message = error.reason
            } else {
                context.message = "Unknown Error"
            }
            if let validationError = error as? KaminoValidateErrors {
                for item in validationError.errors {
                    if let basic = item as? KaminoBasicValidationError {
                        context.fieldset[basic.id] = basic.message
                    }
                }
            }
            return try req.view().render("createEvent", context)
        }
        
        let startDate = WebsiteEventController.dateFormatter.date(from: data.startDate) ?? Date()
        let endDate = WebsiteEventController.dateFormatter.date(from: data.endDate) ?? Date()
        event.name = data.name
        event.password = data.password
        event.startDate = startDate
        event.endDate = endDate
        if let submittedData = data.logo {
            if !submittedData.isEmpty {
                let data = MultipartPart(data: submittedData)
                let logo = data.data
                
                let directory = DirectoryConfig.detect()
                let workingDirectory = directory.workDir
                let name = event.uuid.uuidString + ".png"
                let imageFolder = "/images"
                let saveURL = URL(fileURLWithPath: workingDirectory).appendingPathComponent("/Private"+imageFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
                do {
                    try FileManager.default.createDirectory(atPath: saveURL.deletingLastPathComponent().path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                } catch {
                    print("Error creating folder in documents dir: \(error)")
                    
                }
                try logo.write(to: saveURL)
                event.logoFilename = imageFolder.appending("/").appending(name)
            }
        }
        event.description = data.description
        event.locationName = data.locationName
        event.locationAddress = data.locationAddress
        event.locationAddressLine2 = data.locationAddressLine2
        event.locationCountry = data.locationCountry
        event.locationState = data.locationState
        event.locationPostalCode = data.locationPostalCode
        event.locationCity = data.locationCity
        return event.save(on: req).flatMap(to: View.self, { (event) in
            if isEditing {
                let start = WebsiteEventController.dateFormatter.string(from: event.startDate)
                let end = WebsiteEventController.dateFormatter.string(from: event.endDate)
                
                let data = CreateEventData(name: event.name, password: event.password, confirmPassword: event.password, message: "", startDate: start, endDate: end, logo: nil, description: nil, locationName: event.locationName, locationAddress: event.locationAddress, locationAddressLine2: event.locationAddressLine2, locationCity: event.locationCity, locationCountry: event.locationCountry, locationState: event.locationState, locationPostalCode: event.locationPostalCode, logoFilename: event.logoFilename)
                let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
                var context = CreateEventContext(csrfToken: token, userLoggedIn: true, editing: true, data: data)
                try req.session()["CSRF_TOKEN"] = token
                context.message = "Event Saved"
                return try req.view().render("createEvent", context)
            } else {
                return try req.view().render("event/selectRegistrationForm")
            }
        })
    }
    
    func editEventPostHandler(_ req: Request, data: CreateEventData) throws -> Future<View> {
        return try flatMap(
            to: View.self,
            req.parameters.next(Event.self),
            req.content.decode(CreateEventData.self)) { event, data in
                
                return try self.editOrCreateEventHandler(req, data, event, true)
            }
    }
    
    
    func allUserEventsHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let user = try req.requireAuthenticated(User.self)
        return try flatMap(to: View.self, user.events.query(on: req).all(), user.account.get(on: req)) { (events, account) -> EventLoopFuture<View> in
            let context = AllEventsContext(title: "My Events",
                                           events: events, userLoggedIn: userLoggedIn, user: user.convertToPublic(), account: account.convertToPublic(), fieldset: [:], message: nil)
            return try req.view().render("allEvents", context)
        }
//            return try user.events.query(on: req).all().flatMap(to: View.self) { events in
//                let context = AllEventsContext(title: "My Events",
//                                               events: events, userLoggedIn: userLoggedIn, user: user.convertToPublic(), fieldset: [:], message: nil)
//                return try req.view().render("allEvents", context)
//            }
    }
    
    func teamUserEventsHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.requireAuthenticated(User.self)
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                guard userLoggedIn.accountId == user.accountId else {
                    throw Abort(.unauthorized)
                }
                return try flatMap(to: View.self, user.events.query(on: req).all(),
                                   user.account.get(on: req)) { (events, account) -> EventLoopFuture<View> in
                    let context = AllEventsContext(title: "\(user.username) Events",
                                                   events: events, userLoggedIn: true, user: user.convertToPublic(), account: account.convertToPublic(), fieldset: [:], message: nil)
                    return try req.view().render("allEvents", context)
                }
//            return try user.events.query(on: req).all().flatMap(to: View.self) { events in
//                let context = AllEventsContext(title: "\(user.username) Events",
//                    events: events, userLoggedIn: true, user: user.convertToPublic(), fieldset: [:], message: nil)
//                return try req.view().render("allEvents", context)
//            }
        }
    }
    
    func allEventHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let user = try req.requireAuthenticated(User.self)
        return user.account.get(on: req).flatMap { (account) in
            return try account.events.query(on: req).all().flatMap(to: View.self) { events in
                let context = AllEventsContext(title: "All Team Events",
                                               events: events, userLoggedIn: userLoggedIn, user: user.convertToPublic(), account: account.convertToPublic(), fieldset: [:], message: nil)
                return try req.view().render("allEvents", context)
            }
        }
        

    }
    
    func eventHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Event.self)
            .flatMap(to: View.self) { event in
                return event.user
                    .get(on: req)
                    .flatMap(to: View.self) { user in
                        let context = EventContext(title: "Event Details", event: event, userLoggedIn: true, user: user.convertToPublic(), fieldset: [:], message: nil, form: "basic")
                        return try req.view().render("event", context)
                }
        }
    }
    
    func getEventRegistrationForm(_ req: Request) throws -> Future<View> {
        
        return try KaminoAttendeeRegistrationForm.query(on: req).sort(\.sortOrder, .ascending).all().flatMap(to: View.self, { (forms) -> EventLoopFuture<View> in
            var formData: [RegistrationFormDataContext] = []
            for form in forms {
                let data = RegistrationFormDataContext(description: form.description, name: form.leafName)
                formData.append(data)
            }
            let context = RegistrationFormContext(title: "Select Registration Form", forms: formData)
            try req.view().render("eventRegistrationForms/basic", context).map(to: String.self, { (view) in
                print(view.data.convertToHTTPBody().description)
                return view.data.convertToHTTPBody().description
            })
            return try req.view().render("event/selectRegistrationForm", context)
        })
//        let context = RegistrationFormContext(title: "Select Registration Form", forms: [RegistrationFormDataContext(description: "Basic...", name: "basic"), RegistrationFormDataContext(description: "Minimalist...", name: "minimalist"), RegistrationFormDataContext(description: "basicNoPassword...", name: "basicNoPassword")])
//        try req.view().render("eventRegistrationForms/basic", context).map(to: String.self, { (view) in
//            print(view.data.convertToHTTPBody().description)
//            return view.data.convertToHTTPBody().description
//        })
//        return try req.view().render("event/selectRegistrationForm", context)
//        return try req.parameters.next(Event.self)
//            .flatMap(to: View.self) { event in
//
//                let start = WebsiteEventController.dateFormatter.string(from: event.startDate)
//                let end = WebsiteEventController.dateFormatter.string(from: event.endDate)
//
//                let data = CreateEventData(name: event.name, password: event.password, confirmPassword: event.password, message: "", startDate: start, endDate: end, logo: nil, description: nil, locationName: event.locationName, locationAddress: event.locationAddress, locationAddressLine2: event.locationAddressLine2, locationCity: event.locationCity, locationCountry: event.locationCountry, locationState: event.locationState, locationPostalCode: event.locationPostalCode, logoFilename: event.logoFilename)
//                let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
//                var context = CreateEventContext(csrfToken: token, userLoggedIn: true, editing: true, data: data)
//                context.title = "Edit Event"
//                try req.session()["CSRF_TOKEN"] = token
//                return try req.view().render("createEvent", context)
//        }
    }
    
    func postEventRegistrationForm(_ req: Request) throws -> Future<View> {
        return try req.view().render("event/previewRegistrationForm")
    }
    
}

struct CreateEventContext: Encodable {
    var title = "Create An Event"
    let csrfToken: String
    let userLoggedIn: Bool
    var editing = false
    let data: CreateEventData?
    var message: String?
    var fieldset: [String: String] = [:]
    
    init(csrfToken: String, userLoggedIn: Bool, editing: Bool, data: CreateEventData?, message: String? = nil) {
        self.csrfToken = csrfToken
        self.userLoggedIn = userLoggedIn
        self.editing = editing
        self.data = data
        self.message = message
    }
}

struct CreateEventData: Content {
    let name: String
    let password: String
    let confirmPassword: String
    let message: String?
    let startDate: String
    let endDate: String
    let logo: Data?
    let description: String?
    let locationName: String?
    let locationAddress: String?
    let locationAddressLine2: String?
    let locationCity: String?
    let locationCountry: String?
    let locationState: String?
    let locationPostalCode: String?
    let logoFilename: String?
}

struct AllEventsContext: KaminoContext {
    let title: String
    let events: [Event]
    let userLoggedIn: Bool
    let user: User.Public
    let account: Account.Public
    var fieldset: [String: String] = [:]
    var message: String?

}

struct EventContext: KaminoContext {
    let title: String
    let event: Event
    let userLoggedIn: Bool
    let user: User.Public
    var fieldset: [String: String] = [:]
    var message: String?
    var form: String = "basic"
}

struct RegistrationFormContext: Encodable {
    var title = "Select Registration Form"
    var forms: [RegistrationFormDataContext]
    
}

struct RegistrationFormDataContext: Encodable {
    var description: String
    var name: String
    
}

extension CreateEventData: KaminoValidatable, Reflectable {
    static func validations() throws -> KaminoValidations<CreateEventData> {
        var validations = KaminoValidations(CreateEventData.self)
        
        try validations.add(\.name, .ascii && .count(3...))
        validations.add("date validations") { model in
            guard let startDate = WebsiteEventController.dateFormatter.date(from: model.startDate) else {
                throw KaminoBasicValidationError("Invalid Start Date", "startDate")
            }
            guard let endDate = WebsiteEventController.dateFormatter.date(from: model.endDate) else {
                 throw KaminoBasicValidationError("Invalid End Date", "endDate")
            }
            guard startDate <= endDate else {
                throw KaminoBasicValidationError("End date must be after start date.", "endDate")
            }
            
        }
        validations.add("passwords match") { model in
            guard model.password == model.confirmPassword else {
                var error = KaminoBasicValidationError("passwords don't match", "password")
                error.path = ["password"]
                throw error
            }
        }
        
        return validations
    }
    
    
}




