param ()

$repo = "TITANICBHAI/aria-ai-gemini"

Write-Host "Fetching latest GitHub Action run for $repo..."
$runId = gh run list --repo $repo --limit 1 --json databaseId -q ".[0].databaseId"

if ([string]::IsNullOrWhiteSpace($runId)) {
    Write-Host "No runs found. Make sure you have pushed your changes."
    exit
}

Write-Host "Monitoring run $runId..."
# Wait for the run to complete
gh run watch $runId --repo $repo

# Get the conclusion
$conclusion = gh run list --repo $repo --limit 1 --json conclusion -q ".[0].conclusion"

if ($conclusion -eq "failure") {
    Write-Host "`nRun $runId FAILED. Extracting compilation errors...`n" -ForegroundColor Red
    $logs = gh run view $runId --repo $repo --log
    
    $errors = $logs -split "`n" | Select-String -Pattern "e: "
    
    Write-Host "========== KOTLIN ERRORS ==========" -ForegroundColor Yellow
    foreach ($errorMsg in $errors) {
        Write-Host $errorMsg
    }
    Write-Host "===================================" -ForegroundColor Yellow
    Write-Host "`nAction failed! Please copy the above errors and paste them to the AI agent to fix." -ForegroundColor Cyan
} elseif ($conclusion -eq "success") {
    Write-Host "`nRun $runId completed SUCCESSFULLY! 🎉" -ForegroundColor Green
} else {
    Write-Host "`nRun $runId ended with status: $conclusion" -ForegroundColor Yellow
}
