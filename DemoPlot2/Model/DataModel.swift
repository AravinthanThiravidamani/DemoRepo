//
//  DataModel.swift
//  Ecg
//
//  Created by Aswath Ravichandran on 06/07/22.
//

import Foundation
import ObjectMapper


struct DataModel : Mappable {
    
    var message : String
    var data :String
    
    init?(map: Map) {
                message = ""
                data = ""
            }
        
            mutating func mapping(map: Map) {
                
                data <- map["data"]
                message <- map ["message"]
                
            }

}

