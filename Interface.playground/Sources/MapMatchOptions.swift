//
//  MapMatchOptions.swift
//  MapboxMapMatching
//
//  Created by Matteo Gavagnin on 27/09/2016.
//  Copyright © 2016 Dolomate. All rights reserved.
//

import Foundation

public enum MapMatchProfile {
    case driving
    case cycling
    case walking
}

@objc(DOLMapMatchOptions)
public class MapMatchOptions: NSObject {

    public var profile: MapMatchProfile
    
    public override init() {
        profile = .driving
    }
    
    public init(profile: MapMatchProfile) {
        self.profile = profile
    }
    
    internal var profileString : String {
        switch profile {
        case .cycling:
            return "mapbox.cycling"
        case .driving:
            return "mapbox.driving"
        case .walking:
            return "mapbox.walking"
        }
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        let params: [URLQueryItem] = []

        return params
    }
}
