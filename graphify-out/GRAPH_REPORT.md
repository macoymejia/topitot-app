# Graph Report - topitot-app  (2026-09-03)

## Corpus Check
- 56 files · ~19,078 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 567 nodes · 605 edges · 64 communities (46 shown, 18 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.92)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `36c75cc9`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- package:flutter/material.dart
- aac_home_page.dart
- app_colors.dart
- cell_editor_dialog.dart
- board_models.dart
- app_spacing.dart
- walkthrough_overlay.dart
- board_storage_service.dart
- .application
- board_toolbar.dart
- aac_grid.dart
- cell_visual.dart
- StatelessWidget
- sentence_strip.dart
- aac_tile.dart
- Child-Friendly UI Design Rules
- aac_constants.dart
- Flutter Launcher Logo hdpi
- Launch Screen Assets
- AAC Product Vision
- Flutter Launcher Logo iOS 20 2x
- MainActivity
- board_models.dart
- Custom Cell Photos
- Android Launch Splash Background
- Flutter Launcher Logo iOS 29 1x
- Flutter Mark Logo
- shared_preferences Dependency
- iOS App Icon 87px
- iOS App Icon 40px
- iOS App Icon 80px
- iOS App Icon 120px
- iOS App Icon 120px
- iOS App Icon 76px
- iOS App Icon 152px
- iOS App Icon 167px
- Material Icons Usage
- topitot_app Flutter Package
- Folder-Style Navigation
- Offline-First App
- Architecture Refactor Design
- topitot_app.dart
- Launcher Icons Design
- Transparent Launch Splash Design
- Prepare Google Play Build Design
- Data Safety
- Privacy Policy for Speech Relay by Topitot
- File Structure
- Speech Relay by Topitot Google Play Publishing Checklist
- Next Iteration Feature Notes
- Global Constraints
- Global Constraints
- Global Constraints
- Global Constraints
- Global Constraints
- Global Constraints
- Global Constraints
- First-Run Walkthrough Design

## God Nodes (most connected - your core abstractions)
1. `_` - 20 edges
2. `Architecture Refactor Design` - 12 edges
3. `Launcher Icons Design` - 11 edges
4. `Transparent Launch Splash Design` - 11 edges
5. `Prepare Google Play Build Design` - 11 edges
6. `Privacy Policy for Speech Relay by Topitot` - 10 edges
7. `Data Safety` - 7 edges
8. `Speech Relay by Topitot Google Play Publishing Checklist` - 7 edges
9. `File Structure` - 7 edges
10. `Components` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Portrait-First AAC Experience` --semantically_similar_to--> `Child-Friendly UI Design Rules`  [INFERRED] [semantically similar]
  README.md → AGENTS.md
- `Visual Communication Cells` --semantically_similar_to--> `AAC Button Guidelines`  [INFERRED] [semantically similar]
  README.md → AGENTS.md
- `Topitot AAC App` --references--> `flutter_tts Dependency`  [INFERRED]
  README.md → pubspec.yaml
- `Custom Cell Photos` --references--> `file_picker Dependency`  [INFERRED]
  README.md → pubspec.yaml
- `Custom Cell Photos` --references--> `path_provider Dependency`  [INFERRED]
  README.md → pubspec.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Topitot AAC Experience Principles** — agents_aac_product_vision, agents_accessibility_over_aesthetics, agents_child_friendly_design_rules, agents_aac_button_guidelines, readme_portrait_first_aac_experience [INFERRED 0.85]
- **AAC Board Interaction Flow** — readme_visual_communication_cells, readme_sentence_strip, readme_folder_navigation, readme_topitot_aac_app [EXTRACTED 1.00]
- **Default Flutter Launcher Assets** — android_app_src_main_res_mipmap_mdpi_ic_launcher_flutter_launcher_logo, android_app_src_main_res_mipmap_hdpi_ic_launcher_flutter_launcher_logo, android_app_src_main_res_mipmap_xhdpi_ic_launcher_flutter_launcher_logo, android_app_src_main_res_mipmap_xxhdpi_ic_launcher_flutter_launcher_logo, android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x_flutter_launcher_logo, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x_flutter_launcher_logo [INFERRED 0.95]
- **iOS App Icon Renditions** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x_ios_app_icon_87px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x_ios_app_icon_40px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x_ios_app_icon_80px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x_ios_app_icon_120px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x_ios_app_icon_120px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x_ios_app_icon_180px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x_ios_app_icon_76px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x_ios_app_icon_152px, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x_ios_app_icon_167px [EXTRACTED 1.00]
- **iOS Launch Image Renditions** — ios_runner_assets_xcassets_launchimage_imageset_launchimage_launch_image_1x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x_launch_image_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x_launch_image_3x, ios_runner_assets_xcassets_launchimage_imageset_readme_launch_screen_assets [EXTRACTED 1.00]

## Communities (64 total, 18 thin omitted)

### Community 0 - "package:flutter/material.dart"
Cohesion: 0.06
Nodes (31): app_colors.dart, app_radius.dart, app/topitot_app.dart, app_typography.dart, dart:io, FlutterTts, setup, speak (+23 more)

### Community 1 - "aac_home_page.dart"
Cohesion: 0.04
Nodes (48): BoardLevel get, GlobalKey, AacHomePage, _AacHomePageState, _advanceWalkthrough, _boardStorage, build, _clearSentence (+40 more)

### Community 2 - "app_colors.dart"
Cohesion: 0.06
Nodes (30): accent, AppColors, background, blueSoft, cellSwatches, coralSoft, disabledSurface, editSurface (+22 more)

### Community 3 - "cell_editor_dialog.dart"
Cohesion: 0.05
Nodes (44): bool get, dart:typed_data, _, error, failed, isSaved, matchesPhotoFormat, normalizedPhotoExtension (+36 more)

### Community 4 - "board_models.dart"
Cohesion: 0.08
Nodes (25): blank, BoardLevel, CellKind, cells, CellVisualType, children, clone, color (+17 more)

### Community 5 - "app_spacing.dart"
Cohesion: 0.08
Nodes (22): AppRadius, extraLarge, extraLargeBorder, large, largeBorder, medium, mediumBorder, pill (+14 more)

### Community 6 - "walkthrough_overlay.dart"
Cohesion: 0.12
Nodes (15): CustomPainter, body, build, insetWalkthroughTargetRect, onPrimary, onSkip, paint, primaryLabel (+7 more)

### Community 7 - "board_storage_service.dart"
Cohesion: 0.11
Nodes (17): dart:convert, boardKey, BoardStorageService, loadBoard, saveBoard, hasSeenWalkthrough, markWalkthroughSeen, walkthroughSeenKey (+9 more)

### Community 8 - ".application"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 9 - "board_toolbar.dart"
Cohesion: 0.18
Nodes (10): ../constants/aac_constants.dart, build, depth, editMode, expanded, onEditModeChanged, onExpandedChanged, onReset (+2 more)

### Community 10 - "aac_grid.dart"
Cohesion: 0.15
Nodes (12): aac_tile.dart, build, canGoBack, cells, editMode, enabled, icon, label (+4 more)

### Community 11 - "cell_visual.dart"
Cohesion: 0.15
Nodes (12): BorderRadius, BoxFit, AacCell, borderRadius, build, cell, CellVisual, fit (+4 more)

### Community 12 - "StatelessWidget"
Cohesion: 0.18
Nodes (11): AacGrid, _GridNavigationTile, AacTile, _TileCue, BoardToolbar, _LevelDots, _ToolbarIdentity, _PhotoPickerPanel (+3 more)

### Community 13 - "sentence_strip.dart"
Cohesion: 0.18
Nodes (10): build, enabled, onClear, onRemoveLast, onSpeak, sentence, SentenceStrip, _SentenceUndoButton (+2 more)

### Community 14 - "aac_tile.dart"
Cohesion: 0.18
Nodes (10): cell_visual.dart, Color, IconData, build, cell, editMode, foreground, icon (+2 more)

### Community 15 - "Child-Friendly UI Design Rules"
Cohesion: 0.22
Nodes (9): AAC Button Guidelines, Child-Friendly UI Design Rules, Reusable Design Tokens, flutter_tts Dependency, Focused Flutter Architecture, Portrait-First AAC Experience, Sentence Strip, Topitot AAC App (+1 more)

### Community 16 - "aac_constants.dart"
Cohesion: 0.33
Nodes (5): boardColumns, boardRows, cellsPerPage, maxCellPhotoBytes, maxFolderDepth

### Community 17 - "Flutter Launcher Logo hdpi"
Cohesion: 0.40
Nodes (5): Flutter Launcher Logo hdpi, Flutter Launcher Logo mdpi, Flutter Launcher Logo xhdpi, Flutter Launcher Logo xxhdpi, Flutter Launcher Logo xxxhdpi

### Community 18 - "Launch Screen Assets"
Cohesion: 0.40
Nodes (5): Launch Image 2x, Launch Image 3x, Launch Image 1x, Custom Launch Screen Assets, Launch Screen Assets

### Community 19 - "AAC Product Vision"
Cohesion: 0.50
Nodes (4): AAC Product Vision, Accessibility Over Aesthetics, Topitot Brand Identity, Topitot App

### Community 20 - "Flutter Launcher Logo iOS 20 2x"
Cohesion: 0.50
Nodes (4): Flutter Launcher Logo iOS 1024, Flutter Launcher Logo iOS 20 1x, Flutter Launcher Logo iOS 20 2x, Flutter Launcher Logo iOS 20 3x

### Community 23 - "Custom Cell Photos"
Cohesion: 0.67
Nodes (3): file_picker Dependency, path_provider Dependency, Custom Cell Photos

### Community 44 - "Architecture Refactor Design"
Cohesion: 0.11
Nodes (18): AAC Screen, Acceptance Criteria, App Entry, Architecture Refactor Design, Components, Constants, Context, Data Flow (+10 more)

### Community 45 - "topitot_app.dart"
Cohesion: 0.13
Nodes (15): ../aac/aac_home_page.dart, dart:async, build, createState, dispose, initState, _launchSplashDuration, _launchSplashTimer (+7 more)

### Community 46 - "Launcher Icons Design"
Cohesion: 0.13
Nodes (14): Acceptance Criteria, Components, Context, Data Flow, Error Handling, File Structure, Goal, Launcher Icon Generator (+6 more)

### Community 47 - "Transparent Launch Splash Design"
Cohesion: 0.13
Nodes (14): Acceptance Criteria, Asset registration, Components, Context, Data Flow, Error Handling, File Structure, Goal (+6 more)

### Community 48 - "Prepare Google Play Build Design"
Cohesion: 0.14
Nodes (13): Acceptance Criteria, Command file, Components, Context, Data Flow, Error Handling, File Structure, Goal (+5 more)

### Community 49 - "Data Safety"
Cohesion: 0.15
Nodes (12): Can users request data deletion?, Content Rating, Data Safety, Data safety form answers:, Full Description, Is data collected?, Is data encrypted in transit?, Is data shared? (+4 more)

### Community 50 - "Privacy Policy for Speech Relay by Topitot"
Cohesion: 0.18
Nodes (10): Changes to This Policy, Children's Privacy, Contact, Data Sharing, Device Permissions, How We Use Information, Information We Collect, Privacy Policy for Speech Relay by Topitot (+2 more)

### Community 51 - "File Structure"
Cohesion: 0.20
Nodes (9): Architecture Refactor Implementation Plan, File Structure, Global Constraints, Task 1: Baseline Verification, Task 2: Extract App Entry And AAC Constants, Task 3: Extract Models And Board Storage, Task 4: Extract TTS And Photo Services, Task 5: Extract Reusable AAC Widgets (+1 more)

### Community 52 - "Speech Relay by Topitot Google Play Publishing Checklist"
Cohesion: 0.25
Nodes (7): Play Console steps, Release identity, Release verification, Screenshots needed, Signing, Speech Relay by Topitot Google Play Publishing Checklist, Store listing

### Community 53 - "Next Iteration Feature Notes"
Cohesion: 0.29
Nodes (6): Context, Current Product Direction, Documentation Rules, Next Feature Candidates, Next Iteration Feature Notes, Recent Feature Changes

### Community 54 - "Global Constraints"
Cohesion: 0.33
Nodes (5): Global Constraints, Launcher Icons Implementation Plan, Task 1: Configure launcher icon generation, Task 2: Generate Android and iOS launcher assets, Task 3: Verify the new icons on device and in build outputs

### Community 55 - "Global Constraints"
Cohesion: 0.33
Nodes (5): Global Constraints, Task 1: Register the launch artwork asset, Task 2: Add the transparent launch overlay widget, Task 3: Verify launch behavior and release safety, Transparent Launch Splash Implementation Plan

### Community 56 - "Global Constraints"
Cohesion: 0.50
Nodes (3): Global Constraints, Privacy Policy Implementation Plan, Task 1: Add the Privacy Policy Document

### Community 57 - "Global Constraints"
Cohesion: 0.50
Nodes (3): Global Constraints, Recognizable Word Symbols Implementation Plan, Task 1: Default Symbol Cleanup

### Community 58 - "Global Constraints"
Cohesion: 0.50
Nodes (3): Global Constraints, Task 1: Swap the toolbar mark for the app icon and update the label, Toolbar App Icon Implementation Plan

### Community 59 - "Global Constraints"
Cohesion: 0.50
Nodes (3): Global Constraints, Prepare Google Play Build Implementation Plan, Task 1: Add the Google Play build command

### Community 62 - "Global Constraints"
Cohesion: 0.33
Nodes (5): First-Run Walkthrough Implementation Plan, Global Constraints, Task 1: Add persistence for first-run walkthrough state, Task 2: Add the coach-mark overlay and anchor it to the board screen, Task 3: Cover repeat suppression and validate the app

### Community 63 - "First-Run Walkthrough Design"
Cohesion: 0.33
Nodes (5): Behavior, Fallbacks, First-Run Walkthrough Design, Summary, Visual Treatment

## Knowledge Gaps
- **354 isolated node(s):** `XCTest`, `_boardStorage`, `_walkthroughStorage`, `_ttsService`, `_sentence` (+349 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `cell_editor_dialog.dart` to `package:flutter/material.dart`, `board_toolbar.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `TtsService` connect `package:flutter/material.dart` to `aac_home_page.dart`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `AacCell` connect `cell_visual.dart` to `aac_home_page.dart`, `cell_editor_dialog.dart`, `board_models.dart`, `aac_tile.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `XCTest`, `_boardStorage`, `_walkthroughStorage` to the rest of the system?**
  _354 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._
- **Should `aac_home_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.041666666666666664 - nodes in this community are weakly interconnected._
- **Should `app_colors.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._