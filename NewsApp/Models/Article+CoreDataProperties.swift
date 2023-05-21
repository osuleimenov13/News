//
//  Article+CoreDataProperties.swift
//  NewsApp
//
//  Created by Olzhas Suleimenov on 05.02.2023.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var author: String?
    @NSManaged public var descript: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var viewsCount: Int64
    @NSManaged public var date: String?

}

extension Article : Identifiable {

}
