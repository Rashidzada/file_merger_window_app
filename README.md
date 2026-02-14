# PDF Merger Tool

A Windows desktop application built with Flutter to merge PDF files offline.
Developed as a DIT Final Semester Project by **Amjad Ali**.

## Features

-   **Merge PDFs**: Combine multiple PDF files into one.
-   **Drag & Drop**: Easily add files by dragging them into the window.
-   **Reorder**: Drag and drop items in the list to change their order.
-   **Offline**: All processing happens locally on your computer.
-   **Backup**: Export and Import project lists (JSON format).

## Requirements

-   Windows 10 or 11
-   Flutter SDK (v3.0 or later)
-   Visual Studio (C++ workload) for building Windows apps

## How to Run

1.  **Enable Windows Desktop**:
    ```bash
    flutter config --enable-windows-desktop
    ```

2.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run -d windows
    ```

## How to Build (EXE)

To create a standalone executable for distribution:

```bash
flutter build windows
```

The output file `pdf_merger_tool.exe` will be located in:
`build\windows\runner\Release\`

## Privacy Policy

This application runs 100% offline. No files are uploaded to any server. Your data remains private on your local machine.

## License

DIT Final Semester Project - Peshawar Board.
Uses `syncfusion_flutter_pdf` (Community License applicable for non-commercial/student use).
