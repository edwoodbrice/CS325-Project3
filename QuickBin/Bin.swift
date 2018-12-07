//
//  Bin.swift
//  QuickBin
//
//  Created by User on 12/3/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//

import UIKit
import MapKit
class Bin : NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    public enum BinType : String {
        case Recycle
        case Combustable
        var localizedName: String {
            return self.rawValue + " Bin"
        }
    }
    public let type: BinType
    public var annotationImage: UIImage? {
        switch self.type {
        case .Recycle:
            return UIImage(named: "Recycle")
        default:
            return nil
        }
    }
    // details
    public var thumbnail: UIImage? {
        return self.image
    }
    public private(set) var imageName: String?
    public var image: UIImage? {
        get {
        if let imageName = self.imageName, let resourcePath = Bundle.main.path(forResource: imageName, ofType: "jpg", inDirectory: "Images") {
            return UIImage(contentsOfFile: resourcePath)
        }
        return self.storedImage
        }
        set {
            self.storedImage = newValue
        }
    }
    private var storedImage: UIImage?
    private(set) var builtIn: Bool
    convenience init(_ archivedData: [String : Any]) {
        let coordinate = (archivedData[DataKeys.LocationKey] as! String).components(separatedBy: ",").flatMap { Double($0)}
        self.init(Bin.BinType(rawValue: archivedData[DataKeys.TypeKey] as! String)!, location: CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]))
        self.subtitle = archivedData[DataKeys.descriptionKey] as? String
        self.imageName = archivedData[DataKeys.imageKey] as? String
        self.builtIn = false
    }

    init(_ type: BinType, location: CLLocationCoordinate2D, image: UIImage? = nil, subtitle: String? = nil) {
        self.type = type
        self.coordinate = location
        self.title = self.type.localizedName
        self.subtitle = subtitle
        self.storedImage = image
        self.builtIn = true
    }
    
}
