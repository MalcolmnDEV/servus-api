//
//  Utility.swift
//  App
//
//  Created by Malcolmn Roberts on 2019/01/02.
//

import Foundation
import Fluent

class Utility: NSObject {
    
    /// Singleton
    static let shared = Utility()
    
    // MARK: - Initialisation
    override private init() {
        super.init()
    }
    
    func fetchChildren<Parent: Model, Child: Model, Result>(
        of parents: [Parent],
        idKey: KeyPath<Parent, Parent.ID?> = Parent.idKey,
        via reference: KeyPath<Child, Parent.ID>,
        on conn: DatabaseConnectable,
        combining: @escaping (Parent, [Child]) -> Result) -> Future<[Result]> where Parent.ID: Hashable {
        let parentIDs = parents.compactMap { $0[keyPath: idKey] }
        let children = Child.query(on: conn)
            .filter(reference ~~ parentIDs)
            .all()
        
        return children.map { children in
            let lut = [Parent.ID: [Child]](grouping: children, by: { $0[keyPath: reference] })
            return try parents.map { parent in
                let id = try parent.requireID()
                return combining(parent, lut[id] ?? [])
            }
        }
    }
    
}
