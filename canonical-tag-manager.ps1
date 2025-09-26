#Requires -Version 5.1

<#
.SYNOPSIS
    HTML Canonical Tag Manager - Automatically manage canonical tags in HTML files

.DESCRIPTION
    A PowerShell script that recursively processes HTML files to add, replace, or remove
    canonical tags. Perfect for SEO optimization, website migrations, and bulk HTML management.

.PARAMETER Domain
    The domain name to use for canonical URLs (interactive if not provided)

.PARAMETER Action
    Action to take with existing canonical tags: Skip, Replace, or Remove (interactive if not provided)

.EXAMPLE
    .\canonical-tag-manager.ps1
    Runs the script with interactive prompts

.NOTES
    Author: Community Contribution
    Version: 1.0
    License: MIT
    Requires: PowerShell 5.1+
#>

param(
    [string]$Domain,
    [ValidateSet("Skip", "Replace", "Remove")]
    [string]$Action
)

function Write-Header {
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host "   HTML CANONICAL TAG MANAGER" -ForegroundColor Magenta  
    Write-Host "=====================================" -ForegroundColor Magenta
    Write-Host "Version 1.0 | MIT License" -ForegroundColor Gray
    Write-Host ""
}

function Get-ValidatedDomain {
    param([string]$InitialDomain)
    
    if ($InitialDomain) {
        $domain = $InitialDomain
    } else {
        do {
            $domain = Read-Host "Enter the domain name (e.g., botanical.com, mysite.org, example.net)"
            
            if ([string]::IsNullOrWhiteSpace($domain)) {
                Write-Host "❌ Domain name is required." -ForegroundColor Red
                continue
            }
            
            # Clean up domain (remove http/https, trim spaces, remove trailing slash)
            $domain = $domain.Trim() -replace "^https?://", "" -replace "/$", ""
            
            # Validate domain format
            if ($domain -notmatch "^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
                Write-Host "❌ Invalid domain format. Please enter just the domain (e.g., example.com)" -ForegroundColor Red
                Write-Host "You entered: '$domain'" -ForegroundColor Yellow
                continue
            }
            
            # Confirm the cleaned domain
            Write-Host "Cleaned domain: '$domain'" -ForegroundColor Green
            $confirmDomain = Read-Host "Is this correct? (y/n)"
            
            if ($confirmDomain.ToLower() -eq "y") {
                break
            }
            
        } while ($true)
    }
    
    return $domain
}

function Get-TagAction {
    param([string]$InitialAction)
    
    if ($InitialAction) {
        switch ($InitialAction) {
            "Skip" { return @{Action = "1"; SkipExisting = $true; ReplaceExisting = $false; RemoveOnly = $false} }
            "Replace" { return @{Action = "2"; SkipExisting = $false; ReplaceExisting = $true; RemoveOnly = $false} }
            "Remove" { return @{Action = "3"; SkipExisting = $false; ReplaceExisting = $false; RemoveOnly = $true} }
        }
    }
    
    Write-Host "=== EXISTING CANONICAL TAGS ===" -ForegroundColor Magenta
    Write-Host "What should I do with existing canonical tags?" -ForegroundColor Yellow
    Write-Host "1. Skip files that already have canonical tags (default)" -ForegroundColor White
    Write-Host "2. Replace existing canonical tags with new ones" -ForegroundColor White
    Write-Host "3. Just remove existing canonical tags (no new ones added)" -ForegroundColor White
    
    do {
        $tagAction = Read-Host "Choose option (1/2/3, default: 1)"
        if ([string]::IsNullOrWhiteSpace($tagAction)) { $tagAction = "1" }
        if ($tagAction -in @("1", "2", "3")) { break }
        Write-Host "❌ Please enter 1, 2, or 3" -ForegroundColor Red
    } while ($true)
    
    return @{
        Action = $tagAction
        SkipExisting = $tagAction -eq "1"
        ReplaceExisting = $tagAction -eq "2" 
        RemoveOnly = $tagAction -eq "3"
    }
}

function Process-HTMLFiles {
    param(
        [string]$ScriptDir,
        [array]$HtmlFiles,
        [string]$Domain,
        [bool]$UseBasePath,
        [string]$BasePath,
        [hashtable]$ActionSettings
    )
    
    $processedCount = 0
    $skippedCount = 0
    $errorCount = 0
    
    foreach ($file in $HtmlFiles) {
        Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
        
        try {
            # Get filename without extension
            $filename = $file.BaseName
            
            # Get the full path relative to the script directory
            $relativePath = $file.DirectoryName.Replace($ScriptDir, "").TrimStart("\")
            
            # Build the URL path
            $urlPath = ""
            if ($UseBasePath) {
                $urlPath = $BasePath
            }
            
            if ($relativePath) {
                $pathToAdd = $relativePath -replace "\\", "/"
                if ($UseBasePath) {
                    $urlPath += "/" + $pathToAdd
                } else {
                    $urlPath = $pathToAdd
                }
            }
            
            # Read file content
            $content = Get-Content -Path $file.FullName -Raw
            
            # Check for existing canonical tags
            $hasCanonical = $content -match 'rel="canonical"' -or $content -match "rel='canonical'"
            
            if ($hasCanonical -and $ActionSettings.SkipExisting) {
                Write-Host "  ⚠ Skipped: Canonical tag already exists" -ForegroundColor Yellow
                $skippedCount++
            } 
            elseif ($ActionSettings.RemoveOnly) {
                # Remove existing canonical tags only
                $cleanedContent = $content -replace '<link[^>]*rel=["\x27]canonical["\x27][^>]*>', ''
                $cleanedContent = $cleanedContent -replace '\s*<link[^>]*rel=["\x27]canonical["\x27][^>]*>\s*\r?\n', "`n"
                $cleanedContent | Set-Content -Path $file.FullName -NoNewline
                Write-Host "  🗑 Removed existing canonical tag" -ForegroundColor Cyan
                $processedCount++
            }
            else {
                # Replace existing or add new canonical tag
                if ($hasCanonical -and $ActionSettings.ReplaceExisting) {
                    # Remove existing canonical tags first
                    $content = $content -replace '<link[^>]*rel=["\x27]canonical["\x27][^>]*>', ''
                    $content = $content -replace '\s*<link[^>]*rel=["\x27]canonical["\x27][^>]*>\s*\r?\n', "`n"
                    Write-Host "  🔄 Replacing existing canonical tag" -ForegroundColor Cyan
                } elseif ($hasCanonical) {
                    Write-Host "  ⚠ Skipped: Canonical tag already exists" -ForegroundColor Yellow
                    $skippedCount++
                    continue
                }
                
                # Create canonical URL
                if ($urlPath) {
                    $canonicalUrl = "https://$Domain/$urlPath/$filename.html"
                } else {
                    $canonicalUrl = "https://$Domain/$filename.html"
                }
                
                $canonicalTag = '<link rel="canonical" href="' + $canonicalUrl + '">'
                
                # Replace </title> with </title> + canonical tag on new line
                $titlePattern = '</title>'
                $replacement = '</title>' + "`r`n    " + $canonicalTag
                $newContent = $content -replace $titlePattern, $replacement
                
                # Write back to file
                $newContent | Set-Content -Path $file.FullName -NoNewline
                
                if ($hasCanonical -and $ActionSettings.ReplaceExisting) {
                    Write-Host "  ✅ Replaced with: $canonicalUrl" -ForegroundColor Green
                } else {
                    Write-Host "  ✅ Added: $canonicalUrl" -ForegroundColor Green
                }
                $processedCount++
            }
        }
        catch {
            Write-Host "  ❌ Error processing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
        
        Write-Host ""
    }
    
    return @{
        Processed = $processedCount
        Skipped = $skippedCount
        Errors = $errorCount
    }
}

# Main script execution
try {
    Write-Header

    # Get domain name with validation
    $domain = Get-ValidatedDomain -InitialDomain $Domain
    Write-Host "Using domain: $domain" -ForegroundColor Green
    Write-Host ""

    # Get the directory where the script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    Write-Host "Script directory: $scriptDir" -ForegroundColor Cyan

    # Find all HTML files recursively from current directory
    $htmlFiles = Get-ChildItem -Path $scriptDir -Filter "*.html" -Recurse
    Write-Host "Found $($htmlFiles.Count) HTML files" -ForegroundColor Cyan

    if ($htmlFiles.Count -eq 0) {
        Write-Host "❌ No HTML files found in current directory or subdirectories." -ForegroundColor Red
        Write-Host "Please run this script from a directory containing HTML files." -ForegroundColor Yellow
        return
    }

    # Get the current folder name as base path
    $basePath = Split-Path -Leaf $scriptDir
    Write-Host "Base path: $basePath" -ForegroundColor Cyan
    Write-Host ""
    
    # Ask user if they want to include the current folder in the URL path
    $includeBase = Read-Host "Include current folder '$basePath' in URL paths? (y/n, default: y)"
    if ([string]::IsNullOrWhiteSpace($includeBase)) { $includeBase = "y" }
    $useBasePath = $includeBase.ToLower() -eq "y"
    
    Write-Host ""
    
    # Get tag action settings
    $actionSettings = Get-TagAction -InitialAction $Action
    
    Write-Host ""
    Write-Host "Processing files..." -ForegroundColor Yellow
    Write-Host ""

    # Process all HTML files
    $results = Process-HTMLFiles -ScriptDir $scriptDir -HtmlFiles $htmlFiles -Domain $domain -UseBasePath $useBasePath -BasePath $basePath -ActionSettings $actionSettings

    # Show completion message and summary
    Write-Host "🎉 Complete! All HTML files processed for domain: $domain" -ForegroundColor Green
    
    # Show detailed summary
    Write-Host ""
    Write-Host "=== SUMMARY ===" -ForegroundColor Magenta
    Write-Host "Domain used: '$domain'" -ForegroundColor White
    Write-Host "Total files found: $($htmlFiles.Count)" -ForegroundColor White
    Write-Host "Files processed: $($results.Processed)" -ForegroundColor Green
    Write-Host "Files skipped: $($results.Skipped)" -ForegroundColor Yellow
    Write-Host "Errors encountered: $($results.Errors)" -ForegroundColor Red
    Write-Host "Base path included: $(if ($useBasePath) { 'Yes' } else { 'No' })" -ForegroundColor White
    Write-Host "Action taken: $(
        if ($actionSettings.SkipExisting) { 'Skipped files with existing canonical tags' }
        elseif ($actionSettings.ReplaceExisting) { 'Replaced existing canonical tags' }
        elseif ($actionSettings.RemoveOnly) { 'Removed existing canonical tags only' }
    )" -ForegroundColor White
    
    # Ask if user wants to fix any mistakes
    Write-Host ""
    Write-Host "=== FIX MISTAKES ===" -ForegroundColor Magenta
    $fixMistakes = Read-Host "Did you notice any errors in the URLs? Want to re-run with different settings? (y/n)"
    
    if ($fixMistakes.ToLower() -eq "y") {
        Write-Host ""
        Write-Host "🔄 RE-RUNNING SCRIPT..." -ForegroundColor Cyan
        Write-Host "The script will now remove the canonical tags it just added and let you try again." -ForegroundColor Yellow
        Write-Host ""
        
        # Remove the canonical tags we just added
        foreach ($file in $htmlFiles) {
            try {
                $content = Get-Content -Path $file.FullName -Raw
                # Remove canonical tags (look for the pattern we just added)
                $cleanedContent = $content -replace '\s*<link rel="canonical" href="[^"]*">\r?\n', ''
                $cleanedContent | Set-Content -Path $file.FullName -NoNewline
            }
            catch {
                Write-Host "❌ Error cleaning $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        
        Write-Host "✅ Removed previous canonical tags. Starting fresh..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Press any key to restart the script..."
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        
        # Restart the script by calling it recursively
        & $MyInvocation.MyCommand.Path
        return
    }
}
catch {
    Write-Host "❌ Script Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "❌ Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
}
finally {
    Write-Host ""
    Write-Host "Thank you for using HTML Canonical Tag Manager!" -ForegroundColor Green
    Write-Host "⭐ If this tool helped you, please consider giving it a star on GitHub!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}
