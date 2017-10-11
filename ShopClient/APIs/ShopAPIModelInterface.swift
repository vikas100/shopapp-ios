//
//  ShopAPIModelInterface.swift
//  ShopClient
//
//  Created by Evgeniy Antonov on 10/11/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import Foundation

protocol ShopEntityInterface {
    var entityName: String? { get }
    var entityDesription: String? { get }
    var entityPrivacyPolicy: PolicyEntityInterface? { get }
    var entityRefundPolicy: PolicyEntityInterface? { get }
    var entityTermsOfService: PolicyEntityInterface? { get }
}

protocol PolicyEntityInterface {
    var entityBody: String? { get }
    var entityTitle: String? { get }
    var entityUrl: String? { get }
}