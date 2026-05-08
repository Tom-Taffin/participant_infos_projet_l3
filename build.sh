#!/bin/bash

YELLOW='\033[1;33m'
NC='\033[0m'

projects=(
    "carcassonne_connection_library|git@github.com:Tom-Taffin/carcassonne_connection_library_projet_l3.git|SpectatorMain.jar PlayerMain.jar AdminMain.jar"
    "game-elements|git@github.com:Tom-Taffin/game-elements_projet_l3.git|none"
    "swingplayergui|git@github.com:Tom-Taffin/SwingPlayerGUI_projet_l3.git|PlayerController.jar"
    "programme_arbitre|git@github.com:Tom-Taffin/programme_arbitre_projet_l3.git|RefereeView.jar"
)

build="./build"
buildressources="./build/ressources"
ressources="./ressources/"

echo -e "${YELLOW}starting${NC}"

if [ ! -d "$build" ]; then 
    echo -e "${YELLOW}creating $build${NC}"
    mkdir -p "$build" 
fi

if [ ! -d "$buildressources" ]; then 
    echo -e "${YELLOW}creating $buildressources${NC}"
    mkdir -p "$buildressources" 
fi

for p in "${projects[@]}"; do
   
    IFS="|" read -r dir url jars <<< "$p"

    echo -e "${YELLOW}$dir${NC}"

    # On clone ou on pull
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}pulling...${NC}"
        (cd "$dir" && git pull)
    else
        echo -e "${YELLOW}cloning...${NC}"
        git clone "$url" "$dir"
    fi

    # On compile
    echo -e "${YELLOW}compiling...${NC}"
    pushd "$dir" > /dev/null
    mvn clean install -DskipTests

    if [ $? -ne 0 ]; then
        echo -e "${RED}error when compiling $dir${NC}"
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null

    # On déplace les jars à dans le dossier build
    echo -e "${YELLOW}moving jars...${NC}"
    for jar in $jars; do
        jarPath="./$dir/target/$jar"
        if [ -f "$jarPath" ]; then
            mv "$jarPath" "$build"
            echo -e "${YELLOW}$jar moved${NC}"
        fi
    done

    # On copie les ressources
    echo -e "${YELLOW}moving ressources...${NC}"
    sourceRessources="./$dir/ressources"
    if [ -d "$sourceRessources" ]; then
        cp -r "$sourceRessources/." "$buildressources"
    fi

done

echo -e "${YELLOW}finished${NC}"