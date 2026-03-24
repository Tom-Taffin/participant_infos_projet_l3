$projects = @(
    @{ 
        Name = "carcassonne_connection_library"
        URL = "git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/carcassonne_connection_library.git"
        JarNames = @("SpectatorMain.jar", "PlayerMain.jar", "AdminMain.jar") 
    },
    @{ 
        Name = "game-elements"
        URL = "git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/game-elements.git"
        JarNames = @() 
    },
    @{ 
        Name = "swingplayergui"
        URL = "git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/swingplayergui.git"
        JarNames = @("PlayerController.jar") 
    },
    @{ 
        Name = "programme_arbitre"
        URL = "git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/programme_arbitre.git"
        JarNames = @("RefereeView.jar") 
    }
)



$build = ".\build\"
$buildressources = ".\$build\ressources\"
$ressources = ".\ressources\"

Write-Host "starting" -ForegroundColor Yellow

if (-not (Test-Path $build)) { 
    Write-Host "creating $build" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $build 
}

if (-not (Test-Path $buildressources)) { 
    Write-Host "creating $buildressources" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $buildressources 
}

foreach ($p in $projects) {
    $dir = $p.Name
    $url = $p.URL
    $jar = $p.JarName

    Write-Host "$dir" -ForegroundColor Yellow

    # On clone ou on pull
    if (Test-Path -Path $dir) {
        Write-Host "pulling..." -ForegroundColor Yellow
        Set-Location $dir
        git pull
        Set-Location ..
    } else {
        Write-Host "cloning..." -ForegroundColor Yellow
        git clone $url $dir
    }

    # on compile
    Write-Host "compiling..." -ForegroundColor Yellow
    Push-Location $dir
    mvn clean install -DskipTests

    if ($LASTEXITCODE -ne 0) {
        Write-Host "error when compiling $dir" -ForegroundColor Red
        Pop-Location
        exit $LASTEXITCODE
    }

    Set-Location ..

    # on déplace les jars dans le dossier build
    Write-Host "moving jars..." -ForegroundColor Yellow
    foreach ($jar in $p.JarNames) {
        $jarPath = ".\$dir\target\$jar"
        if (Test-Path $jarPath) {
            Copy-Item -Path $jarPath -Destination "$build" -Force
            Write-Host "$jar moved" -ForegroundColor Yellow
        }
    }

    # on déplace les ressources
    Write-Host "moving ressources..." -ForegroundColor Yellow
    $ressourcesPath = ".\$dir\$ressources\*"
    if (Test-Path $ressourcesPath) {
        Get-ChildItem -Path $ressourcesPath | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $buildressources -Recurse -Force
        }
    }

}

Write-Host "finished" -ForegroundColor Yellow