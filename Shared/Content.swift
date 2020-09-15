//
//  ContentView.swift
//  Shared
//
//  Created by Nicolas Philippe on 9/14/20.
//

import SwiftUI
import SwiftRex
import CombineRex
import CombineRextensions

struct Content: View {
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    
    var body: some View {
        VStack {
            Text(viewModel.state.titleView)
                .font(.title)
                .padding()
            Text("")
            VStack {
                Toggle(
                    viewModel: viewModel,
                    state: \.toggleA.value,
                    onToggle: { ViewAction.toggleA($0) }) {
                    Text(viewModel.state.toggleA.title)
                }
                Toggle(isOn: .constant(false)) {
                    Text(viewModel.state.toggleB.title)
                }
                Toggle(isOn: .constant(false)) {
                    Text("Region Monitoring")
                }
                Toggle(isOn: .constant(false)) {
                    Text("Beacon Ranging")
                }
            }
            .padding()
            VStack {
                Button(action: {}) {
                    Text("Request Location")
                }
            }
            .padding()
            Section(header: Text("Output data").font(.title3)) {
                Text("Position : ")
            }
        }
        
    }
}

struct Content_Previews: PreviewProvider {
    
    static let mockState = Content.ViewState.mock
    static let mockStore = ObservableViewModel<Content.ViewAction, Content.ViewState>.mock(state: mockState)
    
    static var previews: some View {
        Content(viewModel: mockStore)
    }
}

extension Content {
    enum ViewAction {
        case toggleA(Bool)
        case button1Tapped
        case button2Tapped
    }
    
    struct ViewState: Equatable {
        let titleView: String
        let toggleA: ContentItem<Bool>
        let toggleB: ContentItem<Bool>
        let textFieldA: ContentItem<String>
        let textFieldB: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                titleView: "",
                toggleA: ContentItem(title: "", value: false),
                toggleB: ContentItem(title: "", value: false),
                textFieldA: ContentItem(title: "", value: ""),
                textFieldB: ContentItem(title: "", value: "")
            )
        }
        
        static var mock: ViewState {
            .init(
                titleView: "Some Application",
                toggleA: ContentItem(title: "Toggle A :", value: false),
                toggleB: ContentItem(title: "Toggle B :", value: false),
                textFieldA: ContentItem(title: "Title :", value: "A"),
                textFieldB: ContentItem(title: "Title :", value: "B")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
    }
}
