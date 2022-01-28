//
//  PreferencesView.swift
//  KeySwipe
//
//  Created by Gabriel Brito on 1/27/22.
//

import SwiftUI

struct PreferencesView: View {
    
    @EnvironmentObject var applications:Applications
    var allApplication:[Application]
    @State private var appIdx = -1
    
    var body: some View {
        HStack {
            VStack {
                Text("Select application")
                VStack(spacing: 0.0) {
                    HStack(spacing: 0.0) {
                        ButtonImageChanger(idx: 0, allApplication: allApplication)
                        ButtonImageChanger(idx: 1, allApplication: allApplication)
                        ButtonImageChanger(idx: 2, allApplication: allApplication)
                    }
                    HStack(spacing: 0.0) {
                        
                        ButtonImageChanger(idx: 3, allApplication: allApplication)
                        Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                        ButtonImageChanger(idx: 4, allApplication: allApplication)
                        
                    }
                    HStack(spacing: 0.0) {
                        ButtonImageChanger(idx: 5, allApplication: allApplication)
                        ButtonImageChanger(idx: 6, allApplication: allApplication)
                        ButtonImageChanger(idx: 7, allApplication: allApplication)
                    }
                }.padding(.all, 5).background(Color.init(hex: "D3D3D3")).cornerRadius(6).frame(width: 500, height: 210).environmentObject(applications)
                
            }.frame(width: 500, height: 300)
        }
        
    }
    
}

struct ButtonImageChanger: View {
    
    var idx:Int
    var allApplication:[Application]
    @EnvironmentObject var applications:Applications
//    @State private var appIdx = -1
    
    
    var body: some View {
        Picker(selection: $applications.array[idx]) {
            Text("Nothing").tag(nil as Application?)
            ForEach(0..<allApplication.count, id: \.self) { id in
                Text(allApplication[id].name).tag(allApplication[id] as Application?)
            }
        } label: {
//
            if let application=applications.array[idx] {
                Image(nsImage: application.icon).resizable()
                    .frame(maxWidth: 80, maxHeight: 80)
            } else {
                Image(nsImage: NSImage(named: "plus")!).resizable()
                    .frame(maxWidth: 80, maxHeight: 80)
            }
        }.onReceive([applications.array[idx]].publisher.first()) { value in
            Preferences.shared.saveApps()
        }
        
//        Button(action: {
//            print("f")
//            Picker("", selection: $appIdx) {
//                ForEach(applications.array, id: \.self) {
//                    Text($0!.name)
//                }
//            }
//
//        }, label: {
//
//
//            //            Picker("", selection: $appIdx) {
//            //
//            //            }.style
//            //
//            if let application=applications.array[idx] {
//                Image(nsImage: application.icon).resizable()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
//                Image(nsImage: NSImage(named: "plus")!).resizable()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        })
//            .padding(.all, 0.0)
//            .background(content: {
//                Color.clear
//                if let application = applications.array[idx] {
//                    if application.selected {
//                        Color.gray
//                    }
//                }
//            }).cornerRadius(6.0).buttonStyle(BlueButtonStyle())
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        let applications =  Applications()
        let allApplication = AppSearcher().getAllApplications().sorted(by: {$0.name < $1.name})
        QuickPickerView().environmentObject(applications)
    }
}
