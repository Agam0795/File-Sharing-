# Quick Backend Deployment Script
# Run this after you've created a GitHub repository

Write-Host "🚀 DecentraShare Backend Deployment Helper" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get GitHub username
$githubUsername = Read-Host "Enter your GitHub username"

if ([string]::IsNullOrWhiteSpace($githubUsername)) {
    Write-Host "❌ GitHub username is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Instructions:" -ForegroundColor Yellow
Write-Host "1. Go to https://github.com/new" -ForegroundColor White
Write-Host "2. Create a repository named: decentrashare" -ForegroundColor White
Write-Host "3. Keep it PUBLIC" -ForegroundColor White
Write-Host "4. DO NOT initialize with README" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Have you created the GitHub repository? (yes/no)"

if ($continue -ne "yes") {
    Write-Host "⏸️  Please create the repository first, then run this script again" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "📤 Pushing to GitHub..." -ForegroundColor Cyan

# Add remote
git remote remove origin 2>$null
git remote add origin "https://github.com/$githubUsername/decentrashare.git"

# Push
Write-Host "Pushing code to GitHub..." -ForegroundColor White
git branch -M main
git push -u origin main --force

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Go to https://render.com and sign up (use GitHub to sign in)" -ForegroundColor White
    Write-Host "2. Click 'New +' → 'Web Service'" -ForegroundColor White
    Write-Host "3. Connect to your GitHub repository: decentrashare" -ForegroundColor White
    Write-Host "4. Configure the service:" -ForegroundColor White
    Write-Host "   - Name: decentrashare-backend" -ForegroundColor Gray
    Write-Host "   - Region: Oregon (US West)" -ForegroundColor Gray
    Write-Host "   - Branch: main" -ForegroundColor Gray
    Write-Host "   - Root Directory: backend" -ForegroundColor Gray
    Write-Host "   - Runtime: Python 3" -ForegroundColor Gray
    Write-Host "   - Build Command: pip install -r requirements.txt" -ForegroundColor Gray
    Write-Host "   - Start Command: uvicorn main:app --host 0.0.0.0 --port" '$PORT' -ForegroundColor Gray
    Write-Host "5. Add Environment Variable:" -ForegroundColor White
    Write-Host "   - IPFS_API_URL = https://ipfs.infura.io:5001" -ForegroundColor Gray
    Write-Host "6. Click 'Create Web Service'" -ForegroundColor White
    Write-Host ""
    Write-Host "⏱️  Deployment takes 3-5 minutes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Your repository URL:" -ForegroundColor Cyan
    Write-Host "   https://github.com/$githubUsername/decentrashare" -ForegroundColor White
} else {
    Write-Host "❌ Failed to push to GitHub" -ForegroundColor Red
    Write-Host "You may need to authenticate. Try running:" -ForegroundColor Yellow
    Write-Host "   git push -u origin main" -ForegroundColor White
    Write-Host ""
    Write-Host "If you need to authenticate, GitHub will prompt you." -ForegroundColor Yellow
}
