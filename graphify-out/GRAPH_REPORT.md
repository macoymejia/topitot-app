# Graph Report - .  (2026-09-01)

## Corpus Check
- Corpus is ~13,057 words - fits in a single context window. You may not need a graph.

## Summary
- 359 nodes · 404 edges · 44 communities (26 shown, 18 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.92)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- App TTS Setup
- AAC Home State
- Color Tokens
- Cell Editor Dialog
- Board Data Models
- Radius Spacing Tokens
- Photo Storage
- Persistence Typography
- Native App Tests
- Board Toolbar
- AAC Grid Tiles
- Cell Visuals
- AAC UI Components
- Sentence Strip
- Tile Styling
- Product Guidelines
- AAC Constants
- Android Launcher Icons
- Launch Assets
- Brand Vision
- iOS Small Icons
- Android Activity
- Model Barrel Exports
- Photo Dependencies
- Android Splash
- iOS 29 Icons
- Web App Icons
- Local Persistence
- iOS 87 Icon
- iOS 40 Icon
- iOS 80 Icon
- iOS 120 Icon
- iOS 120 Icon
- iOS 76 Icon
- iOS 152 Icon
- iOS 167 Icon
- Material Icons
- Flutter Package
- Folder Navigation
- Offline First

## God Nodes (most connected - your core abstractions)
1. `_` - 20 edges
2. `AacCell` - 5 edges
3. `Launch Screen Assets` - 4 edges
4. `AppDelegate` - 3 edges
5. `RunnerTests` - 3 edges
6. `AacHomePage` - 3 edges
7. `_AacHomePageState` - 3 edges
8. `CellEditorDialog` - 3 edges
9. `_CellEditorDialogState` - 3 edges
10. `Child-Friendly UI Design Rules` - 3 edges

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

## Communities (44 total, 18 thin omitted)

### Community 0 - "App TTS Setup"
Cohesion: 0.06
Nodes (27): ../aac/aac_home_page.dart, app_colors.dart, app_radius.dart, app/topitot_app.dart, app_typography.dart, FlutterTts, setup, speak (+19 more)

### Community 1 - "AAC Home State"
Cohesion: 0.06
Nodes (31): BoardLevel get, AacHomePage, _AacHomePageState, _boardStorage, build, _clearSentence, createState, _currentBoard (+23 more)

### Community 2 - "Color Tokens"
Cohesion: 0.06
Nodes (30): accent, AppColors, background, blueSoft, cellSwatches, coralSoft, disabledSurface, editSurface (+22 more)

### Community 3 - "Cell Editor Dialog"
Cohesion: 0.07
Nodes (27): build, cell, CellEditorDialog, _CellEditorDialogState, _color, createState, depth, dispose (+19 more)

### Community 4 - "Board Data Models"
Cohesion: 0.08
Nodes (25): blank, BoardLevel, CellKind, cells, CellVisualType, children, clone, color (+17 more)

### Community 5 - "Radius Spacing Tokens"
Cohesion: 0.08
Nodes (22): AppRadius, extraLarge, extraLargeBorder, large, largeBorder, medium, mediumBorder, pill (+14 more)

### Community 6 - "Photo Storage"
Cohesion: 0.12
Nodes (17): bool get, dart:typed_data, _, error, failed, isSaved, matchesPhotoFormat, normalizedPhotoExtension (+9 more)

### Community 7 - "Persistence Typography"
Cohesion: 0.13
Nodes (13): dart:convert, boardKey, BoardStorageService, loadBoard, saveBoard, AppTypography, bodyFont, headingFont (+5 more)

### Community 8 - "Native App Tests"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 9 - "Board Toolbar"
Cohesion: 0.14
Nodes (13): ../constants/aac_constants.dart, BoardToolbar, build, depth, editMode, expanded, onEditModeChanged, onExpandedChanged (+5 more)

### Community 10 - "AAC Grid Tiles"
Cohesion: 0.15
Nodes (12): aac_tile.dart, build, canGoBack, cells, editMode, enabled, icon, label (+4 more)

### Community 11 - "Cell Visuals"
Cohesion: 0.15
Nodes (12): BorderRadius, BoxFit, dart:io, AacCell, borderRadius, build, cell, CellVisual (+4 more)

### Community 12 - "AAC UI Components"
Cohesion: 0.17
Nodes (12): AacGrid, _GridNavigationTile, AacTile, _TileCue, _AppIconMark, _LevelDots, _PhotoPickerPanel, _PhotoPreview (+4 more)

### Community 13 - "Sentence Strip"
Cohesion: 0.18
Nodes (10): cell_visual.dart, build, enabled, onClear, onRemoveLast, onSpeak, sentence, List (+2 more)

### Community 14 - "Tile Styling"
Cohesion: 0.18
Nodes (10): Color, IconData, build, cell, editMode, foreground, icon, onTap (+2 more)

### Community 15 - "Product Guidelines"
Cohesion: 0.22
Nodes (9): AAC Button Guidelines, Child-Friendly UI Design Rules, Reusable Design Tokens, flutter_tts Dependency, Focused Flutter Architecture, Portrait-First AAC Experience, Sentence Strip, Topitot AAC App (+1 more)

### Community 16 - "AAC Constants"
Cohesion: 0.33
Nodes (5): boardColumns, boardRows, cellsPerPage, maxCellPhotoBytes, maxFolderDepth

### Community 17 - "Android Launcher Icons"
Cohesion: 0.40
Nodes (5): Flutter Launcher Logo hdpi, Flutter Launcher Logo mdpi, Flutter Launcher Logo xhdpi, Flutter Launcher Logo xxhdpi, Flutter Launcher Logo xxxhdpi

### Community 18 - "Launch Assets"
Cohesion: 0.40
Nodes (5): Launch Image 2x, Launch Image 3x, Launch Image 1x, Custom Launch Screen Assets, Launch Screen Assets

### Community 19 - "Brand Vision"
Cohesion: 0.50
Nodes (4): AAC Product Vision, Accessibility Over Aesthetics, Topitot Brand Identity, Topitot App

### Community 20 - "iOS Small Icons"
Cohesion: 0.50
Nodes (4): Flutter Launcher Logo iOS 1024, Flutter Launcher Logo iOS 20 1x, Flutter Launcher Logo iOS 20 2x, Flutter Launcher Logo iOS 20 3x

### Community 23 - "Photo Dependencies"
Cohesion: 0.67
Nodes (3): file_picker Dependency, path_provider Dependency, Custom Cell Photos

## Knowledge Gaps
- **216 isolated node(s):** `XCTest`, `_boardStorage`, `_ttsService`, `_sentence`, `_path` (+211 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `Photo Storage` to `Board Toolbar`, `Cell Visuals`?**
  _High betweenness centrality (0.052) - this node is a cross-community bridge._
- **Why does `AacCell` connect `Cell Visuals` to `AAC Home State`, `Cell Editor Dialog`, `Board Data Models`, `Tile Styling`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `TtsService` connect `App TTS Setup` to `AAC Home State`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **What connects `XCTest`, `_boardStorage`, `_ttsService` to the rest of the system?**
  _216 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App TTS Setup` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._
- **Should `AAC Home State` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._
- **Should `Color Tokens` be split into smaller, more focused modules?**
  _Cohesion score 0.06451612903225806 - nodes in this community are weakly interconnected._