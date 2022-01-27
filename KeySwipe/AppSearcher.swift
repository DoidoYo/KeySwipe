//
//  AppSearcher.swift
//  KeySnap
//
//  Created by Gabriel Brito on 1/22/22.
//

import Foundation
import AppKit
import SwiftUI

class AppSearcher: NSObject {

    public func getAllApplications() -> [Application] {

        let localApplicationUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .localDomainMask)
        let systemApplicationsUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .systemDomainMask)
        let systemUtilitiesUrls = getApplicationUrlsAt(directory: .applicationDirectory, domain: .systemDomainMask, subpath: "/Utilities")

        let allApplicationUrls = localApplicationUrls + systemApplicationsUrls + systemUtilitiesUrls

        var applications = [Application]()

        for url in allApplicationUrls {
            do {
                let resourceKeys : [URLResourceKey] = [.isExecutableKey, .isApplicationKey]
                let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isApplication! && resourceValues.isExecutable! {
                    let name = url.deletingPathExtension().lastPathComponent
//                    NSWorkspace.shared.icon(forFile: url.path)
                    
                    let rep = NSWorkspace.shared.icon(forFile: url.path).bestRepresentation(for: NSRect(x: 0, y: 0, width: 1024, height: 1024), context: nil, hints: nil)
                    let image = NSImage(size: rep!.size)
                    image.addRepresentation(rep!)
                    applications.append(Application(name: name, url: url, icon: image))
                }
            } catch {}
        }

        return applications
    }

    private func getApplicationUrlsAt(directory: FileManager.SearchPathDirectory, domain: FileManager.SearchPathDomainMask, subpath: String = "") -> [URL] {
        let fileManager = FileManager()

        do {
            let folderUrl = try FileManager.default.url(for: directory, in: domain, appropriateFor: nil, create: false)
            let folderUrlWithSubpath = NSURL.init(string: folderUrl.path + subpath)! as URL

            let applicationUrls = try fileManager.contentsOfDirectory(at: folderUrlWithSubpath, includingPropertiesForKeys: [], options: [FileManager.DirectoryEnumerationOptions.skipsPackageDescendants, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants])

            return applicationUrls
        } catch {
            return []
        }
    }
}


class Applications:ObservableObject {
    @Published var array = [Application?](repeating: nil, count: 8)
}

struct Application {
    var name: String
    var url: URL
    var icon: NSImage
    var selected: Bool = false
}
