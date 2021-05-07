//
//  ContentView.swift
//  StoryListener
//
//  Created by Mohammad Yasir on 07/05/21.
//

import SwiftUI
import CoreData


struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Blog.created, ascending: true)], animation: .default)
    private var blogs: FetchedResults<Blog>
    
    @State private var recording = false
    @ObservedObject private var mic = MicManager(numberOfSamples: 30)
    private var speechManager = SpeechManager()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                
                List {
                    ForEach(blogs) { item in
                        VStack(alignment:.leading , spacing : 10){
                            Text("\(item.created ?? Date())")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)))
                            Text(item.text ?? "")
                                .font(.system(size: 18))
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)))
                        )
                        
                    }
                    .onDelete(perform: deleteItems)

                }
                .navigationTitle("My Stories")
                
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)).opacity(0.7))
                    .padding()
                    .overlay(VStack {
                        VStack {
                            HStack(spacing: 4) {
                                ForEach(mic.soundSamples, id: \.self) { level in
                                    VizualBarView(value: self.normolizedSoundLevel(level: level))
                                }
                            }
                        }
                    })
                    .opacity(recording ? 1 : 0)
                    .frame(width: UIScreen.main.bounds.width - 20, height: 100, alignment: .center)
                    .padding(.bottom , 40)
                
                VStack {
                    Button(action: addItem) {
                        Image(systemName: recording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 40))
                            .padding()
                            .cornerRadius(10)
                    }.foregroundColor(Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)))
                }
                .frame(width: UIScreen.main.bounds.width - 20, height: nil, alignment: .center)
            }.onAppear {
                speechManager.checkPermissions()
            }
        }
    }
    
    
    
    private func normolizedSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2,CGFloat(level) + 50) / 2
        return CGFloat(level * (100 / 25))
    }
    
    private func addItem() {
        if speechManager.isRecording {
            self.recording = false
            mic.stopMonitoring()
            speechManager.stopListening()
        } else {
            self.recording = true
            mic.startMonitoring()
            speechManager.start { (speechText) in
                guard let text = speechText, !text.isEmpty else {
                    self.recording = false
                    return
                }
                
                DispatchQueue.main.async {
                    withAnimation {
                        let newItem = Blog(context: viewContext)
                        newItem.id = UUID()
                        newItem.text = text
                        newItem.created = Date()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        speechManager.isRecording.toggle()
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map{blogs[$0]}.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct VizualBarView: View {
    var value: CGFloat
    let numberOfSamples: Int = 30
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 10) / CGFloat(numberOfSamples), height: value)
        }
    }
    
    
}

// If you want to have a custom desingned Views for your vlogs , you can modify the following
//        ZStack(alignment:.bottom){
//            VStack(alignment:.center){
//                Text("My Blogs")
//                    .font(.system(size: 40, weight: .bold, design: .rounded))
//
//                ScrollView {
//                    ForEach(blogs) { item in
//                        VStack(alignment:.leading){
//                            Text(item.text ?? "")
//                                .padding()
//                        }
//                        .frame(width: UIScreen.main.bounds.width - 20 , height: nil, alignment: .leading)
//                        .padding(.top , 10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)))
//                        )
//
//                    }
//                }.padding()
//
//                Spacer()
//            }
//
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)).opacity(0.7))
//                .padding()
//                .overlay(VStack {
//                    VStack {
//                        HStack(spacing: 4) {
//                            ForEach(mic.soundSamples, id: \.self) { level in
//                                VizualBarView(value: self.normolizedSoundLevel(level: level))
//                            }
//                        }
//                    }
//                })
//                .opacity(recording ? 1 : 0)
//                .frame(width: UIScreen.main.bounds.width - 20, height: 100, alignment: .center)
//                .padding(.bottom , 40)
//
//
//            VStack {
//                Button(action: addItem) {
//                    Image(systemName: recording ? "stop.fill" : "mic.fill")
//                        .font(.system(size: 40))
//                        .padding()
//                        .cornerRadius(10)
//                }.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
//            }
//            .frame(width: UIScreen.main.bounds.width - 20, height: nil, alignment: .center)
//
//        }.onAppear {
//            speechManager.checkPermissions()
//        }
//        .frame(width: UIScreen.main.bounds.width - 20 , height: nil, alignment: .leading)
