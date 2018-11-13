//
//  KaminoController.swift
//  App
//
//  Created by DJ McKay on 9/6/18.
//

import Foundation
import Vapor


struct KaminoApi {
    static var path:String = "api"

}
protocol KaminoController: RouteCollection {
    associatedtype T
    associatedtype Public
    static var path: String { get }
    func createHandler(_ req: Request, entity: T) throws -> Future<Public>
    func getAllHandler(_ req: Request) throws -> Future<[Public]>
    func getHandler(_ req: Request) throws -> Future<Public>
    func updateHandler(_ req: Request) throws -> Future<Public>
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus>
}
