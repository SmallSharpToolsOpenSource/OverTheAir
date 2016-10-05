//#!/usr/bin/swift

// Env Vars:
// OTA_HOST
// OTA_NAME
// OTA_FULL_NAME
// OTA_APP_IDENTIFIER
// OTA_BACKGROUND_COLOR
// OTA_FOREGROUND_COLOR

// Info Plist:
// OTA_VERSION

import Foundation

func loadFile(path: String) -> String? {
    do {
        let contents = try String(contentsOfFile: path)
        return contents
    }
    catch {
        debugPrint(error)
    }
    return nil
}

func env(name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
}

func loadInfoPlist() -> NSDictionary? {
    guard let projectPath = env(name: "PROJECT_DIR"),
        let projectName = env(name: "PROJECT_NAME") else {
        return nil
    }
    let fileURL = URL(fileURLWithPath: projectPath)
        .appendingPathComponent(projectName)
        .appendingPathComponent("Info.plist") 
    return NSDictionary(contentsOf: fileURL)
}

func processTemplates() {
    let manifestPath = "template/manifest.plist"
    let pagePath = "template/install.html"

    if let manifest = loadFile(path: manifestPath),
        let page = loadFile(path: pagePath),
        let infoPlist = loadInfoPlist(),
        let host = env(name: "OTA_HOST"),
        let name = env(name: "OTA_NAME"),
        let fullName = env(name: "OTA_FULL_NAME"),
        let appIdentifier = env(name: "OTA_APP_IDENTIFIER"),
        let backgroundColor = env(name: "OTA_BACKGROUND_COLOR"),
        let foregroundColor = env(name: "OTA_FOREGROUND_COLOR"),
        let version = infoPlist["CFBundleVersion"] as? String {

        // OTA_HOST
        // OTA_NAME
        // OTA_APP_IDENTIFIER
        // OTA_BUNDLE_VERSION
        let updatedManifest = manifest.replacingOccurrences(of: "${OTA_HOST}", with: host)
            .replacingOccurrences(of: "${OTA_NAME}", with: name)
            .replacingOccurrences(of: "${OTA_APP_IDENTIFIER}", with: appIdentifier)
            .replacingOccurrences(of: "${OTA_BUNDLE_VERSION}", with: version)

        // OTA_FULL_NAME
        // OTA_BACKGROUND_COLOR
        // OTA_FOREGROUND_COLOR
        let updatedPage = page.replacingOccurrences(of: "${OTA_FULL_NAME}", with: fullName)
            .replacingOccurrences(of: "${OTA_BACKGROUND_COLOR}", with: backgroundColor)
            .replacingOccurrences(of: "${OTA_FOREGROUND_COLOR}", with: foregroundColor)
            .replacingOccurrences(of: "${OTA_HOST}", with: host)

        let manifestFileURL = URL(fileURLWithPath: "ota")
            .appendingPathComponent("manifest.plist")
        let pageFileURL = URL(fileURLWithPath: "ota")
            .appendingPathComponent("install.html")

        do {
            try updatedManifest.write(to: manifestFileURL, atomically: true, encoding: .utf16)
            try updatedPage.write(to: pageFileURL, atomically: true, encoding: .utf16)
        }
        catch {
            debugPrint(error)
        }
    }
    else {
        debugPrint("error: Unable to process OTA templating.")
    }
}

processTemplates()
