# Update Frontend with Backend URL
# Run this AFTER your backend is deployed

param(
    [Parameter(Mandatory=$true)]
    [string]$BackendURL
)

Write-Host "🔄 Updating Frontend with Backend URL" -ForegroundColor Cyan
Write-Host ""

# Remove trailing slash if present
$BackendURL = $BackendURL.TrimEnd('/')

Write-Host "Backend URL: $BackendURL" -ForegroundColor White
Write-Host ""

# Build frontend with new backend URL
cd frontend

Write-Host "📦 Building frontend..." -ForegroundColor Cyan
$env:VITE_API_URL = $BackendURL
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend built successfully!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "🚀 Deploying to Netlify..." -ForegroundColor Cyan
    cd ..
    netlify deploy --prod
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 SUCCESS! Your app is now fully deployed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Test your backend:" -ForegroundColor Cyan
        Write-Host "   curl $BackendURL/health" -ForegroundColor White
    } else {
        Write-Host "❌ Netlify deployment failed" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Frontend build failed" -ForegroundColor Red
}
