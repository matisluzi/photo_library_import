//
//  ContentView.swift
//  Photo Library Import
//
//  Created by Matis Luzi on 7/28/20.
//  Copyright © 2020 Matis Luzi. All rights reserved.
//

import SwiftUI
import Photos

func getPermission() {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization({status in})
    }
}

struct ContentView: View {
    @State var no_of_files = 0
    @State var no_of_files_failed = 0
    @State var failed_files = [String]()
    @State var failed_files_str = ""
    @State var progress_visible = false
    @State var progress_finished = false
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("import photos into camera roll")
                .font(.title)
                .bold()
            Text("after uploading photos to app data, press button below to upload photos to camera roll:")
            Button(
                action: {
                    self.uploadPhotos()
            },
                label: { Text("upload to camera roll") }
            ).onAppear(perform: getPermission)
            Spacer()
            if progress_visible {
                Text("uploading file " + String(no_of_files) + "...")
            }
            else {
                Text("uploading file " + String(no_of_files) + "...").hidden()
            }
            if progress_finished {
                Text("uploaded " + String(no_of_files - no_of_files_failed) + " files sucessfully.")
                    .foregroundColor(.green)
            }
            else {
                Text("uploaded " + String(no_of_files - no_of_files_failed) + " files sucessfully.")
                    .foregroundColor(.green)
                    .hidden()
            }
            if no_of_files_failed > 0 {
                Text(String(no_of_files_failed) + " files failed to be uploaded:")
                    .foregroundColor(.red)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10){
                        Text(failed_files_str)
                    }
                }
            }
            else {
                Text("uploaded " + String(no_of_files - no_of_files_failed) + " files sucessfully.")
                    .foregroundColor(.green)
                    .hidden()
            }
            Spacer()
        }
    }
    
    func uploadPhotos() {
        progress_visible = true
        let fileManager = FileManager.default
        DispatchQueue.global().async {
            do {
                let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let enumerator = FileManager.default.enumerator(at: documentsURL,
                                                                includingPropertiesForKeys: resourceKeys,
                                                                options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                    print("directoryEnumerator error at \(url): ", error)
                                                                    return true
                })!
                var prev_file = documentsURL
                for case let file as URL in enumerator {
                    let resourceValues = try file.resourceValues(forKeys: Set(resourceKeys))
                    print(file.path, resourceValues.creationDate!, resourceValues.isDirectory!)
                    if prev_file.deletingPathExtension() != file.deletingPathExtension() {
                        print(file.lastPathComponent)
                        self.no_of_files += 1
                    }
                    prev_file = file
                    if ((file.pathExtension == "heic") ||
                        (file.pathExtension == "HEIC") ||
                        (file.pathExtension == "jpg") ||
                        (file.pathExtension == "JPG") ||
                        (file.pathExtension == "jpeg") ||
                        (file.pathExtension == "JPEG") ||
                        (file.pathExtension == "png") ||
                        (file.pathExtension == "PNG")) {
                        
                        do {
                            try PHPhotoLibrary.shared().performChangesAndWait({
                                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: file)
                            })
                        }
                        catch {
                            self.no_of_files_failed += 1
                            self.failed_files.append(String(file.lastPathComponent))
                            self.failed_files_str.append(String(file.lastPathComponent)+"\n")
                        }
                    }
                    else if ((file.pathExtension == "mov") ||
                        (file.pathExtension == "MOV") ||
                        (file.pathExtension == "mp4") ||
                        (file.pathExtension == "MP4")) {
                        
                        do {
                            try PHPhotoLibrary.shared().performChangesAndWait({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: file)
                            })
                        }
                        catch {
                            self.no_of_files_failed += 1
                            self.failed_files.append(String(file.lastPathComponent))
                            self.failed_files_str.append(String(file.lastPathComponent)+"\n")
                        }
                    }
                }
                self.progress_visible = false
                self.progress_finished = true
            } catch {
                print(error)
            }
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
