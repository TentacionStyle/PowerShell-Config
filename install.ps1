# ------------------------------------------------------------------------
# SCRIPT DE INSTALACIÓN AUTOMÁTICA - POWERSHELL ESTILO ZSH (P10K)
# ------------------------------------------------------------------------

# Banner de instalación (Solo se muestra al ejecutar este script)
Clear-Host
Write-Host @"
  _____            _             _             _____ _         _      
 |_   _|__ _ __  _| |_ __ _  ___(_) ___  _ __ /  ___| |_ _   _| | ___ 
   | |/ _ \ '_ \| __/ _` |/ __| |/ _ \| '_ \ \___ \ __| | | | | |/ _ \
   | |  __/ | | | || (_| | (__| | (_) | | | |____) | |_| |_| | |  __/
   |_|\___|_| |_|\__\__,_|\___|_|\___/|_| |_|_____/ \__|\__, |_|\___|
                                                        |___/         
"@ -ForegroundColor Cyan
Write-Host "`n--- Iniciando Instalación de Configuración ---`n" -ForegroundColor White

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"
$fontName = "HackNerdFont-Regular.ttf"
$themeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/bubblesline.omp.json"

# 1. Verificar/Instalar PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[-] PowerShell 7 no detectado. Instalando..." -ForegroundColor Yellow
    winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
    Write-Host "[!] Por favor, reinicia este script usando PowerShell 7 tras la instalación." -ForegroundColor Cyan
    return
}

# 2. Configurar política de ejecución
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 3. Instalación de la Fuente (Hack Nerd Font)
$fontsPath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
if (!(Test-Path (Join-Path $fontsPath $fontName))) {
    Write-Host "[+] Descargando e instalando Hack Nerd Font..." -ForegroundColor Cyan
    if (!(Test-Path $fontsPath)) { New-Item -Path $fontsPath -Type Directory -Force }
    $fontDest = Join-Path $fontsPath $fontName
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontDest
    
    # Registrar la fuente para el usuario actual
    $RegistryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    New-ItemProperty -Path $RegistryPath -Name "Hack Nerd Font Regular (TrueType)" -Value $fontName -PropertyType String -Force
    Write-Host "[✓] Fuente instalada correctamente." -ForegroundColor Green
}

# 4. Instalar Oh My Posh y Fastfetch
Write-Host "[+] Instalando herramientas vía Winget..." -ForegroundColor Cyan
winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
winget install fastfetch --accept-package-agreements --accept-source-agreements

# 5. Instalar Módulos
Write-Host "[+] Instalando módulos de PowerShell..." -ForegroundColor Cyan
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Confirm:$false
Install-Module -Name PSReadLine -AllowPrerelease -Force -SkipPublisherCheck -Confirm:$false

# 6. Preparar archivo de tema local
Write-Host "[+] Configurando tema visual..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $themeUrl -OutFile "$HOME\tema.json"

# 7. Crear Perfil ($PROFILE)
Write-Host "[+] Escribiendo archivo de configuración..." -ForegroundColor Cyan
$ProfileContent = @"
# 1. Forzar iconos y UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Fastfetch minimalista
fastfetch --logo-type small --structure Title:Separator:OS:Kernel:Uptime

# 3. Tema LOCAL
oh-my-posh init pwsh --config "`$HOME\tema.json" | Invoke-Expression

# 4. Módulos y predicciones
Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView

# 5. Alias útiles
function Get-ls-la { Get-ChildItem -Force }
function Get-ls-ll { Get-ChildItem -Force | Format-Table }
function Edit-Profile { notepad `$PROFILE }

Set-Alias -Name la -Value Get-ls-la
Set-Alias -Name ll -Value Get-ls-ll
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name config -Value Edit-Profile
"@

$ProfileDir = Split-Path $PROFILE
if (!(Test-Path $ProfileDir)) { New-Item -Path $ProfileDir -Type Directory -Force }
Set-Content -Path $PROFILE -Value $ProfileContent -Force

Write-Host "`n--- RESUMEN DE CAMBIOS ---" -ForegroundColor Cyan
Write-Host "[√] Terminal: PowerShell 7"
Write-Host "[√] Iconos: Terminal-Icons cargados"
Write-Host "[√] Prompt: Estilo Bubbles (Catppuccin)"
Write-Host "[√] Alias: l, la, ll, config activos"

Write-Host "`n[✓] ¡INSTALACIÓN COMPLETADA CON ÉXITO!" -ForegroundColor Green
Write-Host "[!] IMPORTANTE: Ve a Configuración > PowerShell > Apariencia y selecciona 'Hack NF'." -ForegroundColor Yellow