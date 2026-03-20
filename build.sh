#!/bin/bash

YELLOW='\033[1;33m'
NC='\033[0m'

projects=(
    "carcassonne_connection_library|git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/carcassonne_connection_library.git|none"
    "game-elements|git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/game-elements.git|none"
    "swingplayergui|git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/swingplayergui.git|PlayerController.jar"
    "programme_arbitre|git@gitlab-etu.fil.univ-lille.fr:l3s6-projet-g6-star/programme_arbitre.git|RefereeView.jar"
)

ressources="./ressources/"

echo -e "${YELLOW}starting${NC}"

if [ ! -d "$ressources" ]; then 
    echo -e "${YELLOW}creating $ressources${NC}"
    mkdir -p "$ressources" 
fi

for p in "${projects[@]}"; do
   
    IFS="|" read -r dir url jar <<< "$p"

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

    # On déplace les jars à la racine
    echo -e "${YELLOW}moving jars...${NC}"
    jarPath="./$dir/target/$jar"
    if [ -f "$jarPath" ]; then
        mv "$jarPath" ./
        echo -e "${YELLOW}$jar moved${NC}"
    fi

    # On copie les ressources (comportement Copy-Item -Recurse)
    echo -e "${YELLOW}moving ressources...${NC}"
    sourceRessources="./$dir/ressources"
    if [ -d "$sourceRessources" ]; then
        cp -r "$sourceRessources/." "$ressources"
    fi

done

echo -e "${YELLOW}finished${NC}"