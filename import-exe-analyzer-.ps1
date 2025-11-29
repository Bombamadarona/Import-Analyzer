$ExePath = $null

if (-not $ExePath) {
    Write-Host "@@@@@@    @@@@@@      @@@       @@@@@@@@   @@@@@@   @@@@@@@   @@@  @@@     @@@  @@@@@@@  " -ForegroundColor Cyan
    Write-Host "@@@@@@@   @@@@@@@      @@@       @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@ @@@     @@@  @@@@@@@  " -ForegroundColor Cyan
    Write-Host "!@@       !@@          @@!       @@!       @@!  @@@  @@!  @@@  @@!@!@@@     @@!    @@!    " -ForegroundColor Cyan
    Write-Host "!@!       !@!          !@!       !@!       !@!  @!@  !@!  !@!  !@!!@!@!     !@!    !@!    " -ForegroundColor Cyan
    Write-Host "!!@@!!    !!@@!!       @!!       @!!!:!    @!@!@!@!  @!@!!@!   @!@ !!@!     !!@    @!!    " -ForegroundColor Cyan
    Write-Host " !!@!!!    !!@!!!      !!!       !!!!!:    !!!@!!!!  !!@!@!    !@!  !!!     !!!    !!!    " -ForegroundColor Cyan
    Write-Host "     !:!       !:!     !!:       !!:       !!:  !!!  !!: :!!   !!:  !!!     !!:    !!:    " -ForegroundColor Cyan
    Write-Host "    !:!       !:!       :!:      :!:       :!:  !:!  :!:  !:!  :!:  !:!     :!:    :!:    " -ForegroundColor Cyan
    Write-Host ":::: ::   :::: ::       :: ::::   :: ::::  ::   :::  ::   :::   ::   ::      ::     ::  "  -ForegroundColor Cyan
    Write-Host ":: : :    :: : :       : :: : :  : :: ::    :   : :   :   : :  ::    :      :       :"    -ForegroundColor Cyan
    Write-Host "" -ForegroundColor Cyan
    Write-Host "https://discord.gg/UET6TdxFUk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "|                   IMPORT ANALYZER .EXE                   |" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    
   $ExePath = Read-Host -Prompt "[PATH] Inserire la path del file .exe"

}

function Get-Imports-Simple {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $possibleText = [System.Text.Encoding]::ASCII.GetString($bytes)
    $possibleImports = @("SendMessage", "GetKeyState", "GetAsyncKeyState", "mouse_event", "WriteProcessMemory")
    $found = @()
    foreach ($import in $possibleImports) {
        if ($possibleText -match [regex]::Escape($import)) {
            $found += $import
        }
    }
    return $found
}

function Analyze-Imports {
    param([string[]]$Imports)
    $suspiciousImports = @("SendMessage", "GetKeyState", "GetAsyncKeyState")
    $bannableImports = @("mouse_event", "Mouse_Event")
    $foundSuspicious = @()
    $foundBannable = @()
    foreach ($import in $Imports) {
        if ($suspiciousImports -contains $import) { $foundSuspicious += $import }
        if ($bannableImports -contains $import) { $foundBannable += $import }
    }
    return @{
        Suspicious = $foundSuspicious | Select-Object -Unique
        Bannable   = $foundBannable | Select-Object -Unique
    }
}

try {
    if ([string]::IsNullOrWhiteSpace($ExePath)) {
        Write-Host "[ERRORE] Il parametro -ExePath non è stato fornito o e' vuoto." -ForegroundColor Red
        return
    }
    if (-not (Test-Path $ExePath)) {
        Write-Host "[ERRORE] File non trovato: $ExePath" -ForegroundColor Red
        return
    }

    Write-Host "Analisi degli import di: $ExePath" -ForegroundColor Yellow
    Write-Host ""

    $imports = Get-Imports-Simple -FilePath $ExePath
    if ($imports.Count -eq 0) {
        Write-Host "[SAFE] Nessun import sospetto rilevato" -ForegroundColor Green
        return
    }

    $analysis = Analyze-Imports -Imports $imports

    $results = @()
    foreach ($imp in $analysis.Bannable) {
        $results += [PSCustomObject]@{Import=$imp; Stato="Bannabile"; Info="BAN"; Colore="Red"}
    }
    foreach ($imp in $analysis.Suspicious) {
        $results += [PSCustomObject]@{Import=$imp; Stato="Sospetto"; Info="Controllo"; Colore="Yellow"}
    }
    $safeImports = $imports | Where-Object { ($_ -notin $analysis.Bannable) -and ($_ -notin $analysis.Suspicious) }
    foreach ($imp in $safeImports) {
        $results += [PSCustomObject]@{Import=$imp; Stato="Safe"; Info="-"; Colore="Green"}
    }

    $border = "+" + ("-"*58) + "+"
    Write-Host $border -ForegroundColor DarkGray
    Write-Host ("| {0,-25} | {1,-12} | {2,-13} |" -f "IMPORT", "STATO", "INFO") -ForegroundColor Cyan
    Write-Host $border -ForegroundColor DarkGray

    foreach ($r in $results) {
        Write-Host ("| {0,-25} | {1,-12} | {2,-13} |" -f $r.Import, $r.Stato, $r.Info) -ForegroundColor $r.Colore
    }
} catch {
    Write-Host "[ERRORE] Si è verificato un errore imprevisto: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host "|                    ANALISI COMPLETATA                    |" -ForegroundColor Cyan
Write-Host ("-" + ("=" * 58) + "-") -ForegroundColor Cyan
Write-Host ""
