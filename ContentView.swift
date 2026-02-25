//
//  Firebase039App.swift
//  Firebase039
//
//  Created by Ayesha Mehereen on 25/2/26.
//  2107039

import SwiftUI

struct ContentView: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @State private var showingAddNote = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(firestoreManager.notes) { note in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(note.title).font(.headline)
                                    Text(note.content).font(.subheadline)
                                }
                                Spacer()
                                Button("Delete") {
                                    firestoreManager.deleteNote(note: note)
                                }
                            }
                            .contextMenu {
                                Button("Edit") {
                                    // handle editing note
                                    showingAddNote = true
                                }
                            }
                        
                    }
                }
                .navigationTitle("Notes")
                .navigationBarItems(trailing: Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "plus")
                })
                .onAppear {
                    firestoreManager.getNotes()
                }
                .sheet(isPresented: $showingAddNote, onDismiss: {
                    // refresh list automatically when sheet is closed
                    firestoreManager.getNotes()
                }) {
                    AddNoteView(firestoreManager: firestoreManager)
                }

                Spacer()
                // Footer
                Text("Developed by 2107039")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

