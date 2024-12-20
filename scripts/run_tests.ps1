# Set environment variables (Update these paths based on your system setup)
$env:FLUTTER_PATH = "D:\srs\flutter\bin" # Path to Flutter's bin directory
$env:ADB_PATH = "C:\Users\DELL\AppData\Local\Android\Sdk\platform-tools" # Path to platform-tools directory containing adb.exe

# Variables
$appTarget = "C:\Users\DELL\StudioProjects\trial15\build\app\outputs\flutter-apk\app-debug.apk"
$testResultsLog = "test_results.log"

# Step 1: Build the app
Write-Host "Building the Flutter app..."
& "$env:FLUTTER_PATH\flutter" build apk --debug

if ($LastExitCode -ne 0) {
    Write-Host "Flutter build failed. Exiting script."
    Write-Host "Press Enter to exit."
    Read-Host
    exit 1
}

if (!(Test-Path $appTarget)) {
    Write-Host "Build succeeded, but APK not found at $appTarget. Exiting script."
    Write-Host "Press Enter to exit."
    Read-Host
    exit 1
}

# Step 2: Install the app using ADB
Write-Host "Installing the app on the connected device..."
if (!(Test-Path "$env:ADB_PATH\adb.exe")) {
    Write-Host "adb.exe not found in the specified path: $env:ADB_PATH"
    Write-Host "Press Enter to exit."
    Read-Host
    exit 1
}

& "$env:ADB_PATH\adb.exe" install -r $appTarget

if ($LastExitCode -ne 0) {
    Write-Host "App installation failed. Exiting script."
    Write-Host "Press Enter to exit."
    Read-Host
    exit 1
}

# Step 3: Run the integration tests
Write-Host "Running integration tests..."
& "$env:FLUTTER_PATH\flutter" drive --target=test_driver/app_test.dart > $testResultsLog

if ($LastExitCode -ne 0) {
    Write-Host "Tests failed. Check the log file for details: $testResultsLog"
    Write-Host "Press Enter to exit."
    Read-Host
    exit 1
}

Write-Host "Tests completed successfully. Log file generated: $testResultsLog"
Write-Host "Press Enter to exit."
Read-Host
