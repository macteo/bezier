//
//  MapMatcher.swift
//  MapboxMapMatching
//
//  Created by Matteo Gavagnin on 27/09/2016.
//  Copyright © 2016 Dolomate. All rights reserved.
//

import Foundation
import CoreLocation

typealias JSONDictionary = [String: AnyObject]

/// Indicates that an error occurred in MapMatcher.
public let DOLMapMatcherErrorDomain = "DOLMapMatcherErrorDomain"

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String

/// The user agent string for any HTTP requests performed directly within this library.
let userAgent: String = {
    var components: [String] = []
    
    if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        components.append("\(appName)/\(version)")
    }
    
    let libraryBundle: Bundle? = Bundle(for: MapMatcher.self)
    
    if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String, let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
        components.append("\(libraryName)/\(version)")
    }
    
    let system: String
    #if os(OSX)
        system = "macOS"
    #elseif os(iOS)
        system = "iOS"
    #elseif os(watchOS)
        system = "watchOS"
    #elseif os(tvOS)
        system = "tvOS"
    #elseif os(Linux)
        system = "Linux"
    #endif
    let systemVersion = ProcessInfo().operatingSystemVersion
    components.append("\(system)/\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)")
    
    let chip: String
    #if arch(x86_64)
        chip = "x86_64"
    #elseif arch(arm)
        chip = "arm"
    #elseif arch(arm64)
        chip = "arm64"
    #elseif arch(i386)
        chip = "i386"
    #endif
    components.append("(\(chip))")
    
    return components.joined(separator: " ")
}()

extension CLLocation {
    /**
     Initializes a CLLocation object with the given coordinate pair.
     */
    internal convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

@objc(DOLMapMatcher)
open class MapMatcher: NSObject {
    public typealias CompletionHandler = (_ features: [[CLLocationCoordinate2D]]?, _ attribution: String?, _ error: NSError?) -> Void

    /**
     The shared geocoder object.
     
     To use this object, a Mapbox [access token](https://www.mapbox.com/help/define-access-token/) should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    open static let shared = MapMatcher(accessToken: nil)
    
    /// The API endpoint to request the geocodes from.
    internal var apiEndpoint: URL
    
    /// The Mapbox access token to associate the request with.
    internal let accessToken: String
    
    /**
     Initializes a newly created geocoder object with an optional access token and host.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the geocoder object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     - parameter host: An optional hostname to the server API. The Mapbox Geocoding API endpoint is used by default.
     */
    public init(accessToken: String?, host: String?) {
        let accessToken = accessToken ?? defaultAccessToken
        assert(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://www.mapbox.com/studio/account/tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Geocoder(accessToken:host:) initializer.")
        
        self.accessToken = accessToken!
        
        let baseURLComponents = NSURLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = host ?? "api.mapbox.com"

        self.apiEndpoint = baseURLComponents.url!
    }
    
    /**
     Initializes a newly created geocoder object with an optional access token.
     
     The geocoder object sends requests to the Mapbox Geocoding API endpoint.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the geocoder object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    public convenience init(accessToken: String?) {
        self.init(accessToken: accessToken, host: nil)
    }
    
    open func match(points: [[CLLocationDegrees]], options: MapMatchOptions, completionHandler:@escaping CompletionHandler) -> URLSessionDataTask {
        let geometry : [String : Any] = [
            "type": "Feature",
            "geometry": [
                "type" : "LineString",
                "coordinates": points.map { [$0[1], $0[0]] }
            ]
        ]
        
        return match(route: geometry, options: options, completionHandler: completionHandler)
    }
    
    open func match(points: [[CLLocationDegrees]], times: [Date], options: MapMatchOptions, completionHandler:@escaping CompletionHandler) -> URLSessionDataTask {
        let geometry : [String : Any] = [
            "type": "Feature",
            "properties": [
                "coordTimes" : times.map { Int($0.timeIntervalSince1970) }
            ],
            "geometry": [
                "type" : "LineString",
                "coordinates": points.map { [$0[1], $0[0]] }
            ]
        ]
        
        return match(route: geometry, options: options, completionHandler: completionHandler)
    }

    open func match(coordinates: [CLLocationCoordinate2D], times: [Date], options: MapMatchOptions, completionHandler:@escaping CompletionHandler) -> URLSessionDataTask {
        let geometry : [String : Any] = [
            "type": "Feature",
            "properties": [
                "coordTimes" : times.map { Int($0.timeIntervalSince1970) }
            ],
            "geometry": [
                "type" : "LineString",
                "coordinates": coordinates.map { [$0.longitude, $0.latitude] }
            ]
        ]
        
        return match(route: geometry, options: options, completionHandler: completionHandler)
    }
    
    open func match(coordinates: [CLLocationCoordinate2D], options: MapMatchOptions, completionHandler:@escaping CompletionHandler) -> URLSessionDataTask {
        let geometry : [String : Any] = [
            "type": "Feature",
            "geometry": [
                "type" : "LineString",
                "coordinates": coordinates.map { [$0.longitude, $0.latitude] }
            ]
        ]
        
        return match(route: geometry, options: options, completionHandler: completionHandler)
    }
    
    open func match(route: [String: Any], options: MapMatchOptions, completionHandler:@escaping CompletionHandler) -> URLSessionDataTask {
        let url = urlForMatching(options: options)
        let task = dataTaskWithURL(url, route: route, completionHandler: { (json) in
            assert(json["type"] as? String == "FeatureCollection")
            guard let features = json["features"] as? [[String: AnyObject]] else {
                completionHandler(nil, nil, nil) // TODO: return a valid error here
                return
            }
            let attribution = json["attribution"] as? String
            
            var resultArray = [[CLLocationCoordinate2D]]()
            for feature in features {
                guard let geometry = feature["geometry"] as? [String : Any ] else { break }
                guard let type = geometry["type"] as? String, type == "LineString" else { break }
                var coordinates: [CLLocationCoordinate2D] = []
                
                guard let locations = geometry["coordinates"] as? [[Double]] else { break }
                for location in locations {
                    let coordinate = CLLocationCoordinate2DMake(location[1], location[0])
                    coordinates.append(coordinate)
                }
                resultArray.append(coordinates)
            }
            completionHandler(resultArray, attribution, nil)
        }) { (error) in
            completionHandler(nil, nil, error)
        }
        task.resume()
        return task
    }
    
    /**
     Returns a URL session task for the given URL that will run the given blocks on completion or error.
     
     - parameter url: The URL to request.
     - parameter route: The geojson representation of the requested route
     - parameter completionHandler: The closure to call with the parsed JSON response dictionary.
     - parameter errorHandler: The closure to call when there is an error.
     - returns: The data task for the URL.
     - postcondition: The caller must resume the returned task.
     */
    fileprivate func dataTaskWithURL(_ url: URL, route: [String: Any], completionHandler: @escaping (_ json: [String: AnyObject]) -> Void, errorHandler: @escaping (_ error: NSError) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        // TODO: protect here
        do {
            let data = try JSONSerialization.data(withJSONObject: route, options: [])
            request.httpBody = data
            
            return URLSession.shared.dataTask(with: request) { (data, response, error) in
                var json: JSONDictionary = [:]
                if let data = data, response?.mimeType == "application/json" {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
                    } catch {
                        assert(false, "Invalid data")
                    }
                }
                
                let apiMessage = json["message"] as? String
                guard data != nil && error == nil && apiMessage == nil else {
                    let apiError = MapMatcher.descriptiveError(json, response: response, underlyingError: error as? NSError)
                    DispatchQueue.main.async {
                        errorHandler(apiError)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completionHandler(json)
                }
            }
        } catch let error {
            DispatchQueue.main.async {
                errorHandler(error as NSError)
            }
        }
        return URLSessionDataTask()
    }
    
    /**
     The HTTP URL used to fetch the geocodes from the API.
     */
    open func urlForMatching(options: MapMatchOptions) -> URL {
        let params = options.params + [
            URLQueryItem(name: "access_token", value: accessToken),
        ]
        
        let unparameterizedURL = URL(string: "/matching/v4/\(options.profileString).json", relativeTo: apiEndpoint)!
        var components = URLComponents(url: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }
    
    /**
     Returns an error that supplements the given underlying error with additional information from the an HTTP response’s body or headers.
     */

    fileprivate static func descriptiveError(_ json: JSONDictionary, response: URLResponse?, underlyingError error: NSError?) -> NSError {
        guard error == nil else { return error! }
        var userInfo = [String: Any]()
        if let response = response as? HTTPURLResponse {
            var failureReason: String? = nil
            var recoverySuggestion: String? = nil
            switch response.statusCode {
            case 429:
                if let timeInterval = response.allHeaderFields["x-rate-limit-interval"] as? TimeInterval, let maximumCountOfRequests = response.allHeaderFields["x-rate-limit-limit"] as? UInt {
                    let intervalFormatter = DateComponentsFormatter()
                    intervalFormatter.unitsStyle = .full
                    let formattedInterval = intervalFormatter.string(from: timeInterval)
                    let formattedCount = NumberFormatter.localizedString(from: NSNumber(value: maximumCountOfRequests), number: .decimal)
                    failureReason = "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
                }
                if let rolloverTimestamp = response.allHeaderFields["x-rate-limit-reset"] as? Double {
                    let date = Date(timeIntervalSince1970: rolloverTimestamp)
                    let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .full)
                    recoverySuggestion = "Wait until \(formattedDate) before retrying."
                }
            default:
                failureReason = json["message"] as? String
            }
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?? userInfo[NSLocalizedFailureReasonErrorKey] ?? HTTPURLResponse.localizedString(forStatusCode: response.statusCode )
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion ?? userInfo[NSLocalizedRecoverySuggestionErrorKey]
        }
        userInfo[NSUnderlyingErrorKey] = error
        return NSError(domain: DOLMapMatcherErrorDomain, code: -1, userInfo: userInfo)
    }
}

