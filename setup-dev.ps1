# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO INICIAL PARA NOTEBOOKS DE DESENVOLVEDORES
# Requisito: Executar como Administrador no PowerShell
# ==============================================================================

# 1. Ativar o Modo Desenvolvedor do Windows
Write-Host "Ativando o Modo Desenvolvedor do Windows..." -ForegroundColor Cyan
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -PropertyType DWord -Value 1 -Force | Out-Null

# 2. Configurações de Qualidade de Vida no Windows Explorer
Write-Host "Configurando o Windows Explorer (mostrar extensões e arquivos ocultos)..." -ForegroundColor Cyan
# Mostrar extensões de arquivos conhecidos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
# Mostrar arquivos e pastas ocultos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# 3. Instalação de Ferramentas Essenciais para Devs via Winget
$packages = @(
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "Docker.DockerDesktop",
    "CoreyButler.NVMforWindows",
    "Python.Python.3.12",
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerToys",
    "7zip.7zip"
)

Write-Host "Iniciando a instalação dos programas essenciais..." -ForegroundColor Cyan

foreach ($package in $packages) {
    Write-Host "Instalando: $package" -ForegroundColor Yellow
    winget install --id $package --silent --accept-package-agreements --accept-source-agreements
}

# 4. Ativar recursos de Virtualização (Plataforma de Máquina Virtual e Hipervisor)
Write-Host "Ativando suporte à Virtualização no Windows..." -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart

Write-Host "==================================================================" -ForegroundColor Green
Write-Host " Configuração concluída com sucesso!" -ForegroundColor Green
Write-Host " Recursos de virtualização preparados. Se o dev quiser o WSL," -ForegroundColor Green
Write-Host " bastará rodar 'wsl --install' em um terminal como Admin." -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green