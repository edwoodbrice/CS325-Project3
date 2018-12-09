//
//  DataKeys.swift
//  QuickBin
//
//  Created by User on 12/5/18.
//  Copyright © 2018 cs325-project3. All rights reserved.
//


struct DataKeys {
    public static let LocationKey = "Location"     // type: String, format: (latitude, longtitude). e.g. (100.1, -100.1)
    public static let TypeKey = "Type"             // type: String. e.g. recycle
    public static let descriptionKey = "Description" // type: String. Few explanations to describe where it is. It is optional.
    public static let imageKey = "Image"    // type: String/Data. Image name or stored image data.
}
struct PreferencesKeys {
    public static let lastLocationKey = "LastLocation"
    public static let SplashScreenShownKey = "SplashScreenShown"
}
