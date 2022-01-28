//
//  ContentView.swift
//  KeySnap
//
//  Created by Gabriel Brito on 1/22/22.
//

import SwiftUI

struct QuickPickerView: View {
    
    @EnvironmentObject var applications:Applications
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack(spacing: 0.0) {
                ButtonImage(application: applications.array[0])
                ButtonImage(application: applications.array[1])
                ButtonImage(application: applications.array[2])
            }
            HStack(spacing: 0.0) {
                
                ButtonImage(application: applications.array[3])
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                ButtonImage(application: applications.array[4])
                
            }
            HStack(spacing: 0.0) {
                ButtonImage(application: applications.array[5])
                ButtonImage(application: applications.array[6])
                ButtonImage(application: applications.array[7])
            }
        }.padding(.all, 5).background(Color.init(hex: "D3D3D3")).cornerRadius(6).frame(width: 210, height: 210)
    }
}

struct QuickPickerView_Previews: PreviewProvider {
    static var previews: some View {
        let applications =  Applications()
        QuickPickerView().environmentObject(applications)
    }
}

struct ButtonImage: View {
    
    var application:Application?
    
    var body: some View {
        Button(action: {
            
        }, label: {
            if let application=application {
                Image(nsImage: application.icon).resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        })
            .padding(.all, 0.0)
            .background(content: {
                Color.clear
                if let application = application {
                    if application.selected {
                        Color.gray
                    }
                }
            }).cornerRadius(6.0).buttonStyle(BlueButtonStyle())
    }
}

struct BlueButtonStyle: ButtonStyle {
    @State var isHovered = false
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
