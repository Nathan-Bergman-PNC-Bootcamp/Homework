//
//  Product.swift
//  UIHomework
//
//  Created by Nathan Bergman on 9/8/26.
//

import Foundation

class Product: Identifiable {
    let id: Int
    let name: String
    let productNumber: String
    let color: String
    let listPrice: Double

    init(
        id: Int,
        name: String,
        productNumber: String,
        color: String,
        listPrice: Double
    ) {
        self.id = id
        self.name = name
        self.productNumber = productNumber
        self.color = color
        self.listPrice = listPrice
    }
}
