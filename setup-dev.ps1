# ==============================================================================
# SCRIPT DE CONFIGURACAO INICIAL PARA NOTEBOOKS DE DESENVOLVEDORES
# Uso (PowerShell como Administrador):
#   irm https://gist.githubusercontent.com/Jhow189/c62494109bfb90edda60960232231018/raw/setup-dev.ps1 | iex
# Obs: textos sem acento de proposito - o irm do PowerShell 5.1 quebra UTF-8.
# ==============================================================================

# Tudo dentro de um bloco para nao deixar variaveis/preferencias na sessao de quem roda via iex
& {
    # 0. Verificar se esta rodando como Administrador
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "ERRO: execute o PowerShell como Administrador e rode o comando novamente." -ForegroundColor Red
        return
    }

    # 0.1 Verificar se o winget esta disponivel
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "ERRO: winget nao encontrado. Instale/atualize o 'Instalador de Aplicativo' pela Microsoft Store." -ForegroundColor Red
        return
    }

    $falhas = @()
    $precisaReiniciar = $false

    # 1. Ativar o Modo Desenvolvedor do Windows
    Write-Host "Ativando o Modo Desenvolvedor do Windows..." -ForegroundColor Cyan
    try {
        $chave = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        if (-not (Test-Path $chave)) { New-Item -Path $chave -Force -ErrorAction Stop | Out-Null }
        New-ItemProperty -Path $chave -Name "AllowDevelopmentWithoutDevLicense" -PropertyType DWord -Value 1 -Force -ErrorAction Stop | Out-Null
    } catch {
        $falhas += "Modo Desenvolvedor: $($_.Exception.Message)"
    }

    # 2. Configuracoes de Qualidade de Vida no Windows Explorer
    Write-Host "Configurando o Windows Explorer (mostrar extensoes e arquivos ocultos)..." -ForegroundColor Cyan
    try {
        $explorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        # Mostrar extensoes de arquivos conhecidos
        Set-ItemProperty -Path $explorer -Name "HideFileExt" -Value 0 -ErrorAction Stop
        # Mostrar arquivos e pastas ocultos
        Set-ItemProperty -Path $explorer -Name "Hidden" -Value 1 -ErrorAction Stop
    } catch {
        $falhas += "Windows Explorer: $($_.Exception.Message)"
    }

    # 3. Instalacao de Ferramentas Essenciais para Devs via Winget
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

    # Codigos do winget que nao sao erro: ja instalado / nenhuma atualizacao disponivel
    $codigosOk = @(0, -1978335189, -1978335135)

    Write-Host "Iniciando a instalacao dos programas essenciais..." -ForegroundColor Cyan

    foreach ($package in $packages) {
        Write-Host "Instalando: $package" -ForegroundColor Yellow
        winget install --id $package --exact --silent --accept-package-agreements --accept-source-agreements
        if ($codigosOk -notcontains $LASTEXITCODE) {
            $falhas += "winget $package (codigo $LASTEXITCODE)"
        }
    }

    # 4. Ativar recursos de Virtualizacao (Plataforma de Maquina Virtual e Hipervisor)
    Write-Host "Ativando suporte a Virtualizacao no Windows..." -ForegroundColor Cyan
    foreach ($feature in "VirtualMachinePlatform", "HypervisorPlatform") {
        try {
            $resultado = Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction Stop
            if ($resultado.RestartNeeded) { $precisaReiniciar = $true }
        } catch {
            $falhas += "Recurso ${feature}: $($_.Exception.Message)"
        }
    }

    # 5. Resumo
    Write-Host "==================================================================" -ForegroundColor Green
    if ($falhas.Count -eq 0) {
        Write-Host " Configuracao concluida com sucesso!" -ForegroundColor Green
    } else {
        Write-Host " Configuracao concluida com $($falhas.Count) falha(s):" -ForegroundColor Red
        $falhas | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
    if ($precisaReiniciar) {
        Write-Host " REINICIE o computador para concluir a virtualizacao/Docker." -ForegroundColor Yellow
    }
    Write-Host " Se o dev quiser o WSL, basta rodar 'wsl --install' em um terminal como Admin." -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
}
