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
    public static let locationServiceIsNotAvailableInMapView = "Location Services are not available. Please go to your iPhone Settings and turn on Location Services to enable QuickBin to determine your current location."
    public static let userDidNotSelectAnyReasonsWhenReportABin = "You must select a reason to report."
    public static let userDidNotTypeAnythingInCommentWhenOtherIsSelectedWhenReport = "You must explain your reason to report the bin in the comment section."
    public static let reportSubmittedSuccessfullyPrompt = "The report was submitted. Thank you!"
    public static let userDidNotSelectATypeWhenAddBin = "The bin type (recycling, composting, or trash) was not set. Please select a bin type."
    public static let userDidNotPickLocationWhenAddBin = "Please select your location. You can use your current location or use the map to pick another location."
    public static let warningBeforeRemovingBin = "Do you want to remove this bin? This cannot be undone."
    public static let permissionForCameraIsNotGiven = "QuickBin does not have access to your camera. To take an image, go to your iPhone Settings and enable the camera for QuickBin."
    public static let permissionForPhotoLibraryIsNotGiven = "QuickBin does not have access to your photo library. To access an image, go to your iPhone Settings and enable photo library access for QuickBin."
    public static let currentLocationIsNotAvailableWhenAddBin = "Your current location could not be determined. Try again later or manually set it using the Other Location option."
}
