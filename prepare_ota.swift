#!/usr/bin/swift

import Foundation

func loadFile(path: String) -> String? {
    return try? String(contentsOfFile: path)
}

func env(name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
}

func loadInfoPlist() -> NSDictionary? {
    guard let buildPath = env(name: "TARGET_BUILD_DIR"),
        let appName = env(name: "EXECUTABLE_NAME") else {
        return nil
    }
    let fileURL = URL(fileURLWithPath: buildPath)
        .appendingPathComponent("\(appName).app")
        .appendingPathComponent("Info.plist")
    return NSDictionary(contentsOf: fileURL)
}

func processTemplates() {
    let manifestPath = "template/manifest.plist"
    let pagePath = "template/install.html"
    let bucketPolicyPath = "template/bucket-policy.json"

    guard let manifest = loadFile(path: manifestPath) else {
        debugPrint("error: Unable to load manifest")
        return
    }
    guard let page = loadFile(path: pagePath) else {
        debugPrint("error: Unable to load page")
        return
    }
    guard let bucketPolicy = loadFile(path: bucketPolicyPath) else {
        debugPrint("error: Unable to load bucket policy")
        return
    }
    guard let infoPlist = loadInfoPlist() else {
        debugPrint("error: Unable to load Info.plist")
        return
    }
    guard let otaVariables = infoPlist["OTA_VARIABLES"] as? [String : AnyObject] else {
        debugPrint("error: Unable to load Info.plist")
        return
    }
    guard let host = otaVariables["OTA_HOST"] as? String else {
        debugPrint("error: Unable to load OTA_HOST")
        return
    }
    guard let name = otaVariables["OTA_NAME"] as? String else {
        debugPrint("error: Unable to load OTA_NAME")
        return
    }
    guard let fullName = otaVariables["OTA_FULL_NAME"] as? String else {
        debugPrint("error: Unable to load OTA_NAME")
        return
    }
    guard let appIdentifier = otaVariables["OTA_APP_IDENTIFIER"] as? String else {
        debugPrint("error: Unable to load OTA_APP_IDENTIFIER")
        return
    }
    guard let backgroundColor = otaVariables["OTA_BACKGROUND_COLOR"] as? String else {
        debugPrint("error: Unable to load OTA_BACKGROUND_COLOR")
        return
    }
    guard let foregroundColor = otaVariables["OTA_FOREGROUND_COLOR"] as? String else {
        debugPrint("error: Unable to load OTA_FOREGROUND_COLOR")
        return
    }
    guard let bucketName = otaVariables["OTA_BUCKET_NAME"] as? String else {
        debugPrint("error: Unable to load OTA_BUCKET_NAME")
        return
    }
    guard let version = infoPlist["CFBundleVersion"] as? String else {
        debugPrint("error: Unable to load Bundle Version from Info.plist")
        return
    }

    // OTA_HOST
    // OTA_NAME
    // OTA_APP_IDENTIFIER
    // OTA_BUNDLE_VERSION
    let updatedManifest = manifest.replacingOccurrences(of: "${OTA_HOST}", with: host)
        .replacingOccurrences(of: "${OTA_NAME}", with: name)
        .replacingOccurrences(of: "${OTA_APP_IDENTIFIER}", with: appIdentifier)
        .replacingOccurrences(of: "${OTA_BUNDLE_VERSION}", with: version)
        .replacingOccurrences(of: "${OTA_BUCKET_NAME}", with: bucketName)

    // OTA_FULL_NAME
    // OTA_BACKGROUND_COLOR
    // OTA_FOREGROUND_COLOR
    let updatedPage = page.replacingOccurrences(of: "${OTA_FULL_NAME}", with: fullName)
        .replacingOccurrences(of: "${OTA_BACKGROUND_COLOR}", with: backgroundColor)
        .replacingOccurrences(of: "${OTA_FOREGROUND_COLOR}", with: foregroundColor)
        .replacingOccurrences(of: "${OTA_HOST}", with: host)

    // OTA_BUCKET_NAME
    let updatedBucketPolicy = bucketPolicy.replacingOccurrences(of: "${OTA_BUCKET_NAME}", with: bucketName)

    let manifestFileURL = URL(fileURLWithPath: "ota")
        .appendingPathComponent("manifest.plist")
    let pageFileURL = URL(fileURLWithPath: "ota")
        .appendingPathComponent("install.html")
    let bucketPolicyFileURL = URL(fileURLWithPath: "ota")
        .appendingPathComponent("bucket-policy.json")

    do {
        try updatedManifest.write(to: manifestFileURL, atomically: true, encoding: .utf16)
        try updatedPage.write(to: pageFileURL, atomically: true, encoding: .utf16)
        try updatedBucketPolicy.write(to: bucketPolicyFileURL, atomically: true, encoding: .utf16)
    }
    catch {
        debugPrint("error: Failure writing out OTA files: \(error)")
    }
}

processTemplates()
