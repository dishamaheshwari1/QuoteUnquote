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
    
    @FocusState private var isFocused: Bool
    @State private var showSaveFeedback: Bool = false
    
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604), // Sepia
        Color(red: 0.6, green: 0.05, blue: 0.1),      // Ruby
        Color(red: 0.8, green: 0.3, blue: 0.0),       // Orange
        Color(red: 0.95, green: 0.75, blue: 0.1),     // Yellow
        Color(red: 0.0, green: 0.4, blue: 0.25),      // Emerald
        Color(red: 0.05, green: 0.2, blue: 0.5),      // Sapphire
        Color(red: 0.35, green: 0.1, blue: 0.55),     // Purple
        Color(red: 0.35, green: 0.2, blue: 0.05),     // Brown
        Color(red: 0.25, green: 0.3, blue: 0.35),     // Slate
        Color.black
    ]
    
    var currentText: String { isNewEntryMode ? tempText : quote!.text }
    var currentNote: String { isNewEntryMode ? tempNote : quote!.note }
    var activeColorIndex: Int { isNewEntryMode ? tempColorIndex : (quote?.colorIndex ?? 0) }
    var isLightBackground: Bool { return activeColorIndex == 0 || activeColorIndex == 3 }
    var textColor: Color { isLightBackground ? .black : .white }
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND
            ZStack {
                backgroundColors[activeColorIndex]
                Color.white.opacity(0.04).blendMode(.screen)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: activeColorIndex)
            .onTapGesture { isFocused = false }
            
            // 2. PERFECTLY CENTERED TEXT
            VStack(spacing: 25) {
                TextField("", text: Binding(
                    get: { currentText },
                    set: { val in if isNewEntryMode { tempText = val } else { quote!.text = val } }
                ), prompt: Text("type your quote here").foregroundColor(textColor.opacity(0.35)), axis: .vertical)
                .textFieldStyle(.plain)
                .focusEffectDisabled()
                .fontDesign(.serif)
                .font(.system(size: 38, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .tint(textColor)
                .focused($isFocused)
                // MAIN QUOTE INPUT FIX
                .onKeyPress { keyPress in
                    // We explicitly check that the key is Return AND no modifiers (like Shift) are pressed
                    if keyPress.key == .return && keyPress.modifiers.isEmpty {
                        isFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { saveAction() }
                        return .handled
                    }
                    return .ignored // Let Shift+Enter pass through!
                }
                
                if isNewEntryMode || !currentNote.isEmpty {
                    TextField("", text: Binding(
                        get: { currentNote },
                        set: { val in if isNewEntryMode { tempNote = val } else { quote!.note = val } }
                    ), prompt: Text("note to self...").foregroundColor(textColor.opacity(0.35)))
                    .textFieldStyle(.plain)
                    .focusEffectDisabled()
                    .fontDesign(.serif)
                    .font(.title3)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor.opacity(0.6))
                    .tint(textColor)
                    .focused($isFocused)
                    // MAIN QUOTE INPUT FIX
                    .onKeyPress { keyPress in
                        // We explicitly check that the key is Return AND no modifiers (like Shift) are pressed
                        if keyPress.key == .return && keyPress.modifiers.isEmpty {
                            isFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { saveAction() }
                            return .handled
                        }
                        return .ignored // Let Shift+Enter pass through!
                    }
                }
            }
            .frame(maxWidth: 650)
            .padding(.horizontal, 40)
            
            // 3. KEYBOARD SHORTCUTS
            Group {
                Button("") { changeColor(direction: -1) }.keyboardShortcut(.leftArrow, modifiers: .command)
                Button("") { changeColor(direction: 1) }.keyboardShortcut(.rightArrow, modifiers: .command)
            }.opacity(0)
            
            // 4. FEEDBACK
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
        
        // 5. MINIMALIST TOOLBAR
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
                        NavigationLink(destination: QuoteListView()) {
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
                
                Button(action: { /* Share */ }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(textColor)
                        .padding(14)
                        .background(isLightBackground ? Color.white.opacity(0.4) : Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
    
    // ... (Keep your existing deleteAction, changeColor, and saveAction exactly as they were)
    
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
            modelContext.insert(newQuote)
            withAnimation { showSaveFeedback = true }
            tempText = ""; tempNote = ""; isFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation { showSaveFeedback = false } }
        } else {
            withAnimation { showSaveFeedback = true }
            isFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation { showSaveFeedback = false } }
        }
    }
}
