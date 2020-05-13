//
//  DownloadView.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 3/19/20.
//  Copyright © 2020 BaseMap. All rights reserved.
//

import SwiftUI
import AccuTerraSDK

struct DownloadView: View {
    
    @ObservedObject var mapInteraction = MapInteraction()
    @ObservedObject var downloadViewModel = DownloadViewModel()

    @State var goHome = false
    
    private let maxValue: Double = 100
    private let controlForegroundColor:UIColor = .red
    
    var alert: Alert {
        Alert(title: Text("Download Status"),
        message: Text("Success! Proceeding to map."),
        dismissButton: .default(Text("OK"))  {
            self.goHome = true
        })
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                NavigationLink(destination: HomeView(), isActive: $goHome) {
                    HStack {
                        Text("")
                        Spacer()
                    }
                    .padding() .background(Color.white).cornerRadius(3)
                }
                GeometryReader { geometry in
                    VStack(spacing: 30) {
                        ProgressCircle(value: self.downloadViewModel.downloadPercentage,
                                   maxValue: self.maxValue,
                                   style: .dotted,
                                   foregroundColor: Color(self.controlForegroundColor),
                                   lineWidth: 10)
                            .frame(height: 100)
                   
                        Text("Trails Database Download").foregroundColor(.white)
                        Text("\(self.downloadViewModel.downloadPercentString)").foregroundColor(.white)
                    }
                    .frame(height: 300.0)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(.gray)
                    .opacity(0.75)
                    .shadow(color: .gray, radius: 10, x: 3, y: 3)
                }
                .padding(.vertical)
                .padding(.horizontal, 36)
            }
            .onAppear {
                if self.downloadViewModel.loadingState == .loading {
                    self.downloadViewModel.fetchTrails()
                }
            }
            .alert(isPresented: $downloadViewModel.downloadSuccess, content: { self.alert })
            .edgesIgnoringSafeArea([.top, .bottom])
        }
        .navigationBarTitle("AccuTerra Download")
        .navigationBarHidden(true)
    }
}

struct ProgressCircle: View {
    enum Stroke {
        case line
        case dotted
        
        func strokeStyle(lineWidth: CGFloat) -> StrokeStyle {
            switch self {
            case .line:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round)
            case .dotted:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round,
                                   dash: [12])
            }
        }
    }
    
    private let value: Double
    private let maxValue: Double
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineWidth: CGFloat
    
    init(value: Double,
         maxValue: Double,
         style: Stroke = .line,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = Color(UIColor(red: 245/255,
                                                green: 245/255,
                                                blue: 245/255,
                                                alpha: 1.0)),
         foregroundColor: Color = Color.black,
         lineWidth: CGFloat = 10) {
        self.value = value
        self.maxValue = maxValue
        self.style = style
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            if self.backgroundEnabled {
                Circle()
                    .stroke(lineWidth: self.lineWidth)
                    .foregroundColor(self.backgroundColor)
            }
            
            Circle()
                .trim(from: 0, to: CGFloat(self.value / self.maxValue))
                .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                .foregroundColor(self.foregroundColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeIn)
        }
    }
}


