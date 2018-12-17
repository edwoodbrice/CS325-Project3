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
struct LocalizedString {
    public static let locationServiceIsNotAvailableInMapView = "Location Services is not available. Please go to settings and turn on location services to determine current location."
    public static let userDidNotSelectAnyReasonsWhenReportABin = "You must select a reason to report."
    public static let userDidNotTypeAnythingInCommentWhenOtherIsSelectedWhenReport = "You must explain in comment if you choose other reasons."
    public static let reportSubmittedSuccessfullyPrompt = "The report is submitted. Thank you."
    public static let userDidNotSelectATypeWhenAddBin = "Type is not set. Please select one type"
    public static let userDidNotPickLocationWhenAddBin = "Location is not determined."
    public static let warningBeforeRemovingBin = "Do you want to remove this bin on the map? This operation cannot be undone."
    public static let permissionForCameraIsNotGiven = "The permission to access camera is not given. "
    public static let permissionForPhotoLibraryIsNotGiven = "The permission to access photo library is not given. "
    public static let currentLocationIsNotAvailableWhenAddBin = "Current location is not available."
}
