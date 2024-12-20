# Navigate to the project root directory
Set-Location -Path "C:/Users/DELL/StudioProjects/trial15"

# Remove the old test results log if it exists
Remove-Item -ErrorAction Ignore -Path .\test_results.log

# Run Gift Model Unit Tests
Write-Output "Running Gift Model Tests..." | Out-File -Append -FilePath test_results.log -Encoding utf8
flutter test test/unit_test_gift.dart 2>&1 | Out-String | Out-File -Append -FilePath test_results.log -Encoding utf8
if ($LASTEXITCODE -eq 0) {
    Add-Content -Path test_results.log -Value "`nGift Model Tests Passed`n"
} else {
    Add-Content -Path test_results.log -Value "`nGift Model Tests Failed`n"
}

# Run Friend Model Unit Tests
Write-Output "Running Friend Model Tests..." | Out-File -Append -FilePath test_results.log -Encoding utf8
flutter test test/unit_test_user_friend.dart 2>&1 | Out-String | Out-File -Append -FilePath test_results.log -Encoding utf8
if ($LASTEXITCODE -eq 0) {
    Add-Content -Path test_results.log -Value "`nFriend Model Tests Passed`n"
} else {
    Add-Content -Path test_results.log -Value "`nFriend Model Tests Failed`n"
}

Write-Output "All tests completed. Check 'test_results.log' for details." | Out-File -Append -FilePath test_results.log -Encoding utf8
