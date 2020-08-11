//
//  ContentView.swift
//  Photo Library Import
//
//  Created by Matis Luzi on 7/28/20.
//  Copyright © 2020 Matis Luzi. All rights reserved.
//

import SwiftUI
import Photos

// Content View
struct ContentView: View {
    
    // Variables that change UI elements
    @State var varHeight:CGFloat = 0
    @State var no_of_files = 0
    @State var no_of_files_failed = 0
    @State var failed_files = [String]()
    @State var failed_files_str = ""
    @State var progress_visible = false
    @State var progress_finished = false
    @State var progress:Double = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 20) {
                
                Spacer()
                
                // Title text
                title
                Spacer()
                
                // Instructions
                info
                Spacer()
                
                // Upload button
                HStack {
                    Spacer()
                    Button(action: uploadPhotos) {
                        Text("Upload")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color(.systemIndigo))
                    .cornerRadius(20)
                    
                    Spacer()
                }
                
                Spacer()
                
            }.padding()
            // end of vstack
            
            // progress view
            progressView
            
            // finished view
            finishedView
        }
    }
    
    private var title: some View {
        Text("Photo Library Import")
            .font(.largeTitle)
            .bold()
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Instructions")
                .font(.system(size: 22, weight: .bold, design: .default))
            
            Text("Use iTunes (or Finder) to upload the pictures into the app's folder, like the picture below:")
            
            Image("instructions")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(2)
                .shadow(radius: 5)
                .pinchToZoom()
                .zIndex(1)
            
            Text("Afterwards, press the button below to upload the photos into the Camera Roll.")
        }
    }
    
    private var progressView: some View {
        ZStack {
            if progress_visible {
                BlurView(style: .regular)
                    .frame(width: 200, height: 100)
                    .cornerRadius(5)
                VStack(spacing: 20) {
                    Text("Uploading images...")
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: 180, height: 10)
                            .foregroundColor(.secondary)
                            .cornerRadius(3)
                        Rectangle()
                            .frame(width: 180*CGFloat(progress), height: 10)
                            .foregroundColor(.primary)
                            .cornerRadius(3)
                    }
                }
            }
        }
    }
    
    private var finishedView: some View {
        VStack {
            
            // if no files failed
            if progress_finished && no_of_files_failed == 0 {
                ZStack {
                    BlurView(style: .regular)
                        .frame(width: 300, height: nil)
                        .cornerRadius(5)
                    VStack(spacing: 20) {
                        Text("Uploaded " + String(no_of_files - no_of_files_failed) + " files sucessfully.")
                        Button(action: {
                            progress_finished = false
                            no_of_files = 0
                            no_of_files_failed = 0
                        }, label: {
                            Text("Ok")
                                .foregroundColor(.white)
                                .bold()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                        })
                        .background(Color(.systemIndigo))
                        .cornerRadius(5)
                    }
                }.frame(width: 300, height: 100)
            }
            
            // if there are files that failed
            else if progress_finished && no_of_files_failed > 0 {
                ZStack {
                    BlurView(style: .regular)
                        .frame(width: 300, height: nil)
                        .cornerRadius(5)
                    VStack(spacing: 20) {
                        Spacer()
                        Text("Uploaded " + String(no_of_files - no_of_files_failed) + " files sucessfully.")
                        Text(String(no_of_files_failed) + " files failed to be uploaded:")
                            .foregroundColor(.red)
                        
                        // Scroll view of failed files
                        ScrollView(.vertical) {
                            Text(failed_files_str)
                        }
                        
                        Button(action: {
                            progress_finished = false
                            no_of_files = 0
                            no_of_files_failed = 0
                        }, label: {
                            Text("Ok")
                                .foregroundColor(.white)
                                .bold()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                        })
                        .background(Color(.red))
                        .cornerRadius(5)
                        
                    }.padding(20)
                }.frame(width: 300, height: 230)
            }
        }
    }
    
    // END OF MAIN VIEW
    
    // Function that uploads pictures
    func countPhotos() {
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
                }
            } catch {
                print(error)
            }
        }
    }
    func uploadPhotos() {
        countPhotos()
        withAnimation(.easeInOut) {
            progress_visible = true
        }
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
                for case let file as URL in enumerator {
                    let resourceValues = try file.resourceValues(forKeys: Set(resourceKeys))
                    print(file.path, resourceValues.creationDate!, resourceValues.isDirectory!)
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
                            withAnimation(.easeInOut) {
                                progress += 1/Double(no_of_files)
                            }
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
                            withAnimation(.easeInOut) {
                                progress += 1/Double(no_of_files)
                            }
                        }
                        catch {
                            self.no_of_files_failed += 1
                            self.failed_files.append(String(file.lastPathComponent))
                            self.failed_files_str.append(String(file.lastPathComponent)+"\n")
                        }
                    }
                }
                self.progress_visible = false
                progress = 0
                withAnimation(.easeInOut) {
                    self.progress_finished = true
                }
            } catch {
                print(error)
            }
        }
    }
}


// Get user permission to access photos
func getPermission() {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization({status in})
    }
}

// DEBUG
struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
