# LifePlanner
Roys Planner
OG PROMPT 
Act as an expert macOS Developer. I want to build a menu-bar-only utility app using SwiftUI for macOS Sequoia. 

Project Goal: A "Smart Reminder" app that lives in the Menu Bar (system tray). 
User Flow: User clicks the menu bar icon -> A small popover opens -> User types a reminder like "Dinner with girlfriend at 7" -> The app uses a simple local Naive Bayes classifier (or basic word-frequency probability) to automatically tag it as "Girlfriend".

Tech Stack:
- Swift/SwiftUI (macOS 15+)
- No external heavy ML libraries (implement the "ML" logic in pure Swift for speed/memory).
- Persistence: SwiftData or simple JSON storage.

Requirements for Phase 1 (The Plan):
1. Plan a MenuBarController using NSStatusItem to show the app in the toolbar.
2. Plan a "Classifier" engine: Create a list of hardcoded categories (Girlfriend, Classes, Social, SHPE, LUL, Groceries, Gym).
3. Implement a simple 'Word Counter' logic that learns: if a reminder contains "lifting" or "bench", it's 90% likely "Gym". If it's "meeting" or "exam", it's "Classes".
4. Design a clean, minimal Popover UI with an TextField and a "Smart Categorized" label that updates as the user types.

Please provide a file-by-file plan. Do not write all the code yet; I want to review the architecture first. If think of a better categorizing strategey suggest it 