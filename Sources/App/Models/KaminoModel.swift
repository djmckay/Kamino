//
//  Kamino.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor
import FluentMySQL

protocol KaminoModel: MySQLUUIDModel {
    
    associatedtype Public
    func convertToPublic() -> Public
    
//    static var createdAtKey: TimestampKey? { get }
//    static var updatedAtKey: TimestampKey? { get }
//    var createdAt: Date? { get set }
//    var updatedAt: Date? { get set }
}



protocol KaminoUserTrackable: KaminoModel {
    
    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}

