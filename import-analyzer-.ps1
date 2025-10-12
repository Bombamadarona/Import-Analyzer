if (-not $ExePath) {
    Write-Host "@@@@@@    @@@@@@      @@@       @@@@@@@@   @@@@@@   @@@@@@@   @@@  @@@     @@@  @@@@@@@  " -ForegroundColor Cyan
    Write-Host "@@@@@@@   @@@@@@@      @@@       @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@ @@@     @@@  @@@@@@@  " -ForegroundColor Cyan
    Write-Host "!@@       !@@          @@!       @@!       @@!  @@@  @@!  @@@  @@!@!@@@     @@!    @@!    " -ForegroundColor Cyan
    Write-Host "!@!       !@!          !@!       !@!       !@!  @!@  !@!  @!@  !@!!@!@!     !@!    !@!    " -ForegroundColor Cyan
    Write-Host "!!@@!!    !!@@!!       @!!       @!!!:!    @!@!@!@!  @!@!!@!   @!@ !!@!     !!@    @!!    " -ForegroundColor Cyan
    Write-Host " !!@!!!    !!@!!!      !!!       !!!!!:    !!!@!!!!  !!@!@!    !@!  !!!     !!!    !!!    " -ForegroundColor Cyan
    Write-Host "     !:!       !:!     !!:       !!:       !!:  !!!  !!: :!!   !!:  !!!     !!:    !!:    " -ForegroundColor Cyan
    Write-Host "    !:!       !:!       :!:      :!:       :!:  !:!  :!:  !:!  :!:  !:!     :!:    :!:    " -ForegroundColor Cyan
    Write-Host ":::: ::   :::: ::       :: ::::   :: ::::  ::   :::  ::   :::   ::   ::      ::     ::  "  -ForegroundColor Cyan
    Write-Host ":: : :    :: : :       : :: : :  : :: ::    :   : :   :   : :  ::    :      :       :"    -ForegroundColor Cyan
    Write-Host "" -ForegroundColor Cyan
    Write-Host "https://discord.gg/UET6TdxFUk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "`n------------------------------------------" -ForegroundColor DarkGray
    Write-Host "            IMPORT ANALYZER .EXE"
    Write-Host "------------------------------------------`n" -ForegroundColor DarkGray
    Write-Output "" 
    $ExePath = Read-Host "Inserisci il percorso completo del file .exe da analizzare"
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

    $suspiciousImports = @(
        "SendMessage",
        "GetKeyState",
        "GetAsyncKeyState"
    )

    $bannableImports = @(
        "mouse_event",
        "WriteProcessMemory"
    )

    $foundSuspicious = @()
    $foundBannable = @()

    foreach ($import in $Imports) {
        if ($suspiciousImports -contains $import) {
            $foundSuspicious += $import
        }
        if ($bannableImports -contains $import) {
            $foundBannable += $import
        }
    }

    $foundSuspicious = $foundSuspicious | Select-Object -Unique
    $foundBannable = $foundBannable | Select-Object -Unique

    return @{
        Suspicious = $foundSuspicious
        Bannable   = $foundBannable
    }
}

try {
    if ([string]::IsNullOrWhiteSpace($ExePath)) {
        Write-Host "[ERRORE] Il parametro -ExePath non è stato fornito o è vuoto." -ForegroundColor Red
        return
    }
    if (-not (Test-Path $ExePath)) {
        Write-Host "[ERRORE] File non trovato: $ExePath" -ForegroundColor Red
        return
    }

    Write-Host "`nAnalisi degli import di: $ExePath" -ForegroundColor Yellow
    Write-Host ""

    $imports = Get-Imports-Simple -FilePath $ExePath

    if ($imports.Count -eq 0) {
        Write-Host "`[OK] Nessun import sospetto rilevato." -ForegroundColor Green
        return
    }

    $analysis = Analyze-Imports -Imports $imports

    if ($analysis.Bannable.Count -ge 1) {
        Write-Host "`-Il programma contiene import bannabili:" -ForegroundColor Red
        Write-Host ""
        foreach ($bann in $analysis.Bannable) {
            Write-Host "   - $bann" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "-Bannare l'utente." -ForegroundColor Red
    }
    elseif ($analysis.Suspicious.Count -ge 2) {
        Write-Host "`n -Il programma contiene più di un import sospetto:" -ForegroundColor DarkYellow
        foreach ($susp in $analysis.Suspicious) {
            Write-Host "   - $susp" -ForegroundColor DarkYellow
        }
        Write-Host "-Altamente sospetto, valutare ban o ulteriori indagini." -ForegroundColor DarkYellow
    }
    elseif ($analysis.Suspicious.Count -eq 1) {
        Write-Host "`n -Il programma contiene solo un import sospetto:" -ForegroundColor Yellow
        foreach ($susp in $analysis.Suspicious) {
            Write-Host "   - $susp" -ForegroundColor Yellow
        }
        Write-Host "-Non è sufficiente per il ban automatico." -ForegroundColor Yellow
    }
    else {
        Write-Host "`n [OK] Nessun import sospetto rilevato." -ForegroundColor Green
    }
}
catch {
    Write-Host "`n [ERRORE] Si è verificato un errore imprevisto: $_" -ForegroundColor Red
}
