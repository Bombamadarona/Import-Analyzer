# 🔍 Import-Analyzer (PowerShell)
Questa stringa permette di controllare se un programma .exe può essere un autoclicker tramite il controllo degli Imports.

Questo script è stato realizzato dal server discord SS LEARN IT (https://discord.gg/UET6TdxFUk).

## 🔍 Funzionalità

- Analisi Import.
- Import Bannabili se trova funzioni come mouse_event o WriteProcessMemory, segnala che il programma può essere bannato.
- Import Sospetti se trova due o più tra SendMessage, GetKeyState, GetAsyncKeyState, il programma è considerato sospetto.
- Riporta i risultati direttamente sul powershell

## 📂 Programmi analizzati

- Qualsiasi path di un programma in .exe installato

## ▶️ Utilizzo

1. Apri PowerShell (amministratore).
2. Copia e incolla lo script nel terminale oppure salvalo in un file, ad esempio `import-analyzer.ps1`.
3. Esegui lo script:
`.\import-analyzer.ps1`

Oppure puoi semplicemente eseguire lo script tramite un comando senza scaricare il file:

1. Apri PowerShell (amministratore).
2. `iex (iwr -useb https://raw.githubusercontent.com/Bombamadarona/Import-Analyzer/refs/heads/main/import-analyzer-.ps1")`
