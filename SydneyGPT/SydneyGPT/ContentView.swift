//
//  ContentView.swift
//  SydneyGPT
//
//  Created by Josepher Shunaula on 5/4/23.
//

import SwiftUI
import AVKit
//import PythonKit
 

struct ContentView: View {
    @State var isRecording = false
    @State var audioSession: AVAudioSession!
    @State var audioRecorder: AVAudioRecorder!
    @State var microphoneAlert = false
    @State var audioFileURL: URL?
    @State var messages: [String] = ["msg 1", "msg 2", "msg 3"]
    @State var audioFiles: [String] = []


    var body: some View {
        NavigationView {
            VStack {
                ScrollView {

                    VStack(alignment: .leading) {
                        ForEach(messages, id: \.self) { message in

                            HStack(alignment: .top, spacing: 12) {

                                // Black circle as profile picture
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 30, height: 30)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(message)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                        .lineLimit(nil)
                                }
                                Spacer()
                            }.padding(.bottom, 4)
                        }
                    }
                }

                Spacer()

                Button(action: recordingButtonPressed) {

                    Image("mic1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 125)
                        .padding(50)
                        //.foregroundColor(self.isRecording ? Color.white : Color.blue)
                        .foregroundColor(.green)
                        .padding(15)
                        .background(self.isRecording ? Color.red : Color.yellow)
                        .clipShape(Circle())
                }

                Spacer()
                Spacer()
                Spacer()


            }

            .navigationTitle("SydneyGPT")
            .navigationBarTitleDisplayMode(.inline)
            .padding()

        }

        .alert(isPresented: self.$microphoneAlert, content: {
            Alert(title: Text("Permission Error"), message: Text("Microphone permission required"))
        })

    }

    

    func recordingButtonPressed() {
        // Start recording - Done
        // Save to mp3 to wav - Done

        if self.isRecording {
            var filePath = self.stopRecording()
            getTranscription(filePath: filePath)
            
        } else {
            self.startRecording()
        }

        self.isRecording.toggle()
        // pass to whisper (Savar will create fun to call to)
        // return form whisper show prompt

 

    }

    func startRecording() {
        do {
            self.audioSession = AVAudioSession.sharedInstance()
            try self.audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.audioSession.requestRecordPermission { (isGranted) in

                DispatchQueue.main.async {
                    if isGranted {
                        let recordingName = "recording\(self.audioFiles.count + 1).wav"
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let soundFileURL = documentsDirectory.appendingPathComponent(recordingName)
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatLinearPCM),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 2,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]

                        do {
                            self.audioRecorder = try AVAudioRecorder(url: soundFileURL, settings: settings)
                            self.audioRecorder.record()
                            self.audioFileURL = soundFileURL
                        } catch let error {
                            print("Error starting recording: \(error.localizedDescription)")
                        }
                    } else {
                        self.microphoneAlert.toggle()
                    }
                }
            }
        } catch let error {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }


    func stopRecording() -> String {
        self.audioRecorder.stop()
        self.audioRecorder = nil
        if let audioFileURL = self.audioFileURL {
            print(audioFileURL.lastPathComponent)
            self.audioFiles.append(audioFileURL.lastPathComponent)
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFile = documentsDirectory.appendingPathComponent(audioFileURL.lastPathComponent)
            do {
                try fileManager.moveItem(at: audioFileURL, to: audioFile)
                print("Audio file saved to: \(audioFile)")
                return "\(audioFile)"
            } catch let error {
                print("Error saving audio file: \(error.localizedDescription)")
            }
        }
        print(audioFiles)
        return "ERROR"
    }
    
    
    
    // idk why savar want this but i say yippy do
    func getTranscription(filePath: String) {
            guard let url = URL(string: "http://127.0.0.1:5000/transcribe") else {
                print("Invalid URL")
                return
            }
            
            // Prepare the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Set the request body data
        let requestBody: [String: Any] = ["audio_file_path": filePath, "convo": messages]
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
            
            // Set the request headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Make the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                
                if let data = data {
                    // Process the response data
                    
                    messages.append("\(String(data: data, encoding: .utf8) ?? "")")
                    print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }.resume()
        }


}