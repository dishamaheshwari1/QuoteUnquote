//
//  QuoteEditorView.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

struct QuoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let quote: Quote?
    var isFromLibrary: Bool = false
    var isNewEntryMode: Bool { quote == nil }
    
    @State private var tempText: String = ""
    @State private var tempNote: String = ""
    @State private var tempColorIndex: Int = 0
    @State private var tempDate: Date = Date()
    @State private var showDatePicker: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var showSaveFeedback: Bool = false
    
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604),
        Color(red: 0.6, green: 0.05, blue: 0.1),
        Color(red: 0.8, green: 0.3, blue: 0.0),
        Color(red: 0.95, green: 0.75, blue: 0.1),
        Color(red: 0.0, green: 0.4, blue: 0.25),
        Color(red: 0.05, green: 0.2, blue: 0.5),
        Color(red: 0.35, green: 0.1, blue: 0.55),
        Color(red: 0.35, green: 0.2, blue: 0.05),
        Color(red: 0.25, green: 0.3, blue: 0.35),
        Color.black
    ]
    
    var currentText: String { isNewEntryMode ? tempText : quote!.text }
    var currentNote: String { isNewEntryMode ? tempNote : quote!.note }
    var activeColorIndex: Int { isNewEntryMode ? tempColorIndex : (quote?.colorIndex ?? 0) }
    var isLightBackground: Bool { return activeColorIndex == 0 || activeColorIndex == 3 }
    var textColor: Color { isLightBackground ? .black : .white }
    
    var dynamicQuoteFontSize: CGFloat {
        let length = currentText.count
        let baseSize = 38.0
        let minSize = 18.0
        let maxCharsToScale = 200.0
        let progress = min(1.0, CGFloat(max(0, length - 40)) / maxCharsToScale)
        return baseSize - ((baseSize - minSize) * progress)
    }
    
    var dynamicNoteFontSize: CGFloat {
        let length = currentNote.count
        let baseSize = 20.0
        let minSize = 14.0
        let maxCharsToScale = 100.0
        let progress = min(1.0, CGFloat(max(0, length - 20)) / maxCharsToScale)
        return baseSize - ((baseSize - minSize) * progress)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                backgroundColors[activeColorIndex]
                Color.white.opacity(0.04).blendMode(.screen)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: activeColorIndex)
            .onTapGesture { isFocused = false }
            
            VStack(spacing: 25) {
                TextField("", text: Binding(
                    get: { currentText },
                    set: { val in if isNewEntryMode { tempText = val } else { quote!.text = val } }
                ), prompt: Text("type your quote here").foregroundColor(textColor.opacity(0.35)), axis: .vertical)
                .textFieldStyle(.plain)
                .focusEffectDisabled()
                .fontDesign(.serif)
                .font(.system(size: dynamicQuoteFontSize, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .tint(textColor)
                .focused($isFocused)
                .animation(.interactiveSpring, value: dynamicQuoteFontSize)
                .onKeyPress { keyPress in
                    if keyPress.key == .return {
                        if keyPress.modifiers.isEmpty {
                            isFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { saveAction() }
                            return .handled
                        }
                    }
                    return .ignored
                }
                
                TextField("", text: Binding(
                    get: { currentNote },
                    set: { val in if isNewEntryMode { tempNote = val } else { quote!.note = val } }
                ), prompt: Text("note to self...").foregroundColor(textColor.opacity(0.35)))
                .textFieldStyle(.plain)
                .focusEffectDisabled()
                .fontDesign(.serif)
                .font(.system(size: dynamicNoteFontSize, weight: .regular).italic())
                .multilineTextAlignment(.center)
                .foregroundColor(textColor.opacity(0.6))
                .tint(textColor)
                .focused($isFocused)
                .animation(.interactiveSpring, value: dynamicNoteFontSize)
                .onKeyPress { keyPress in
                    if keyPress.key == .return {
                        if keyPress.modifiers.isEmpty {
                            isFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { saveAction() }
                            return .handled
                        }
                    }
                    return .ignored
                }
            }
            .frame(maxWidth: 650)
            .padding(.horizontal, 40)
            .padding(.vertical, 80)
            
            Group {
                Button("") { changeColor(direction: -1) }.keyboardShortcut(.leftArrow, modifiers: .command)
                Button("") { changeColor(direction: 1) }.keyboardShortcut(.rightArrow, modifiers: .command)
            }.opacity(0)
            
            if showSaveFeedback {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(textColor.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .focusable()
        .focusEffectDisabled()
        .onAppear {
            if let existingDate = quote?.dateCreated {
                tempDate = existingDate
            }
        }
        // THE FIX: Perfect twin Help Button, dynamically colored!
        .overlay(alignment: .topTrailing) {
            NavigationLink(destination: OnboardingView()) {
                Image(systemName: "questionmark")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(textColor)
                    .padding(14)
                    .background(isLightBackground ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .focusable(false)
            .focusEffectDisabled()
            .padding(.trailing, 40)
            .padding(.top, 30)
        }
        // BOTTOM TOOLBAR & SHARE
        .overlay(alignment: .bottom) {
            HStack {
                HStack(spacing: 22) {
                    if !currentText.isEmpty {
                        Button(action: saveAction) {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Button(action: {
                        showDatePicker.toggle()
                        isFocused = false
                    }) {
                        Image(systemName: "calendar")
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .focusEffectDisabled()
                    .foregroundColor(textColor)
                    .popover(isPresented: $showDatePicker, arrowEdge: .top) {
                        DatePicker("", selection: $tempDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                            .onChange(of: tempDate) { _, newDate in
                                if !isNewEntryMode { quote?.dateCreated = newDate }
                            }
                    }
                    
                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    
                    if isFromLibrary {
                        Button(action: { dismiss() }) {
                            Image(systemName: "square.grid.2x2")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                    } else {
                        NavigationLink(destination: GalleryView()) {
                            Image(systemName: "square.grid.2x2")
                        }
                        .buttonStyle(.plain)
                        .focusable(false)
                    }
                }
                .font(.system(size: 20, weight: .light))
                .foregroundColor(textColor)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(isLightBackground ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                .clipShape(Capsule())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentText.isEmpty)
                
                Spacer()
                
                ShareLink(
                    item: generateSnapshot(),
                    preview: SharePreview("Vellum Quote", image: generateSnapshot())
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(textColor)
                        .padding(14)
                        .background(isLightBackground ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .disabled(currentText.isEmpty)
                .opacity(currentText.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
    
    @MainActor
    func generateSnapshot() -> Image {
        let exportView = QuoteSnapshotView(
            text: currentText.isEmpty ? " " : currentText,
            note: currentNote,
            backgroundColor: backgroundColors[activeColorIndex],
            textColor: textColor
        )
        
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 2.0
        
        if let cgImage = renderer.cgImage {
            return Image(cgImage, scale: 1.0, label: Text("Quote"))
        }
        return Image(systemName: "photo")
    }
    
    func deleteAction() {
        withAnimation {
            if isNewEntryMode {
                tempText = ""; tempNote = ""; isFocused = false
            } else {
                if let q = quote {
                    modelContext.delete(q)
                    if isFromLibrary { dismiss() }
                }
            }
        }
    }
    
    func changeColor(direction: Int) {
        withAnimation {
            let count = backgroundColors.count
            let current = activeColorIndex
            var newIndex = current + direction
            if newIndex < 0 { newIndex = count - 1 }
            else if newIndex >= count { newIndex = 0 }
            
            if isNewEntryMode { tempColorIndex = newIndex }
            else { quote!.colorIndex = newIndex }
        }
    }
    
    func saveAction() {
        if isNewEntryMode {
            guard !tempText.isEmpty else { return }
            let newQuote = Quote(text: tempText, note: tempNote, colorIndex: tempColorIndex)
            newQuote.dateCreated = tempDate
            modelContext.insert(newQuote)
            
            withAnimation { showSaveFeedback = true }
            tempText = ""; tempNote = ""; isFocused = false
            tempDate = Date()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation { showSaveFeedback = false } }
        } else {
            withAnimation { showSaveFeedback = true }
            isFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation { showSaveFeedback = false } }
        }
    }
}

// --- OFF-SCREEN EXPORT TEMPLATE ---
struct QuoteSnapshotView: View {
    let text: String
    let note: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        ZStack {
            backgroundColor
            Color.white.opacity(0.04).blendMode(.screen)
            
            VStack(spacing: 30) {
                Text(text)
                    .fontDesign(.serif)
                    .font(.system(size: 46, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
                
                if !note.isEmpty {
                    Text(note)
                        .fontDesign(.serif)
                        .font(.title2)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(textColor.opacity(0.8))
                }
            }
            .padding(80)
        }
        .frame(width: 1000, height: 1000)
    }
}
