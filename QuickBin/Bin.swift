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
        case Compost
        case Trash
        var localizedName: String {
            return self.rawValue + " Bin"
        }
        var numericValue: Int {
            switch self {
                case .Recycle:
                    return 0
                case .Compost:
                    return 1
                case .Trash:
                    return 2
            }
        }
        init?(_ numericValue: Int) {
            switch numericValue {
            case 0:
                self = .Recycle
            case 1:
                self = .Compost
            case 2:
                self = .Trash
            default:
                return nil
            }
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
    // high-res image may cause memory issue. Considering store in data.
    private var storedImage: UIImage?
    private(set) var builtIn: Bool
    private(set) var identifier: String

    var archivedPropertyList: (String, [String : Any]) {
        var archivedDic = [String : Any]()
        if let imageName = self.imageName {
            // not possible for user create bins.
            archivedDic[DataKeys.imageKey] = imageName
            fatalError("Internal Inconsistency.")
        }
        else if let image = self.storedImage, let imageData = UIImagePNGRepresentation(image) {
            // probably bad to store image to data in plist.
            archivedDic[DataKeys.imageKey] = imageData
        }
        archivedDic[DataKeys.TypeKey] = self.type.rawValue
        if let description = self.subtitle {
            archivedDic[DataKeys.descriptionKey] = description
        }
        archivedDic[DataKeys.LocationKey] = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        return (self.identifier, archivedDic)
    }

    convenience init(_ archivedData: [String : Any], builtIn: Bool, identifier: String?) {
        let coordinate = (archivedData[DataKeys.LocationKey] as! String).components(separatedBy: ",").flatMap { Double($0)}
        self.init(Bin.BinType(rawValue: archivedData[DataKeys.TypeKey] as! String)!, location: CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1]), image: nil, subtitle: archivedData[DataKeys.descriptionKey] as? String, builtIn: builtIn, identifier: identifier)
        if let imageData = archivedData[DataKeys.imageKey] as? Data {
            self.image = UIImage(data: imageData)
        }
        else {
            self.imageName = archivedData[DataKeys.imageKey] as? String
        }
    }

    init(_ type: BinType, location: CLLocationCoordinate2D, image: UIImage? = nil, subtitle: String? = nil, builtIn: Bool = false, identifier: String? = nil) {
        self.type = type
        self.coordinate = location
        self.title = self.type.localizedName
        self.subtitle = subtitle
        self.storedImage = image
        self.builtIn = builtIn
        self.identifier = identifier ?? uniqueIDGenerator()
    }
    
}
