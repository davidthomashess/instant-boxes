#!/bin/bash
ISNPM=$(command -v npm)

if [[ -z $ISNPM ]]
then
  echo "Node.js has not been installed!"
  echo "Please install Node.js from: https://nodejs.org/en/"
  echo "Exit typo.sh"
  exit 1
fi

echo "[::New Project Setup::]"
echo "What type of Project? "
read THEME
echo "Name of Vite Project?"
read PROJECT

PROJECTLOWER=$(echo ${PROJECT} | awk '{print tolower($0)}')
echo ${PROJECTLOWER}




file_builder() {
  CONTENT=$1
  FILE=$2
  echo "$CONTENT" > $FILE
  CONTENT=$(tail +2 ${FILE})
  echo "$CONTENT" > $FILE
  echo "$(awk '/^$/{n=n RS}; /./{printf "%s",n; n=""; print}' $FILE)" > $FILE
  truncate -s -1 $FILE

  TABCOUNT=$(head -n 1 $FILE | awk -F'[^ ]' '{print length($1)}')
  CONTENT=$(awk '{print substr($0,"'"$(( $TABCOUNT + 1 ))"'")}' $FILE)
  echo "$CONTENT" > $FILE
}

if [ -d "./${THEME}/${PROJECT}" ] 
then
  echo "[${THEME}] with [${PROJECT}]: Is taken!"
  exit 1
else
  if [ -d "./${THEME}" ]
  then
    echo "${THEME}: Type of project already exists!"
    echo "System will skip to setup ${PROJECT} in the ${THEME} directory"
  else
    echo "Making [${THEME}] directory"
    mkdir $THEME
  fi

  echo "Making the project: [${PROJECT}]"
  # mkdir $THEME/$PROJECT/
  eval cd $THEME/
  npm create vite@latest $PROJECTLOWER -- --template react-ts
  mv $PROJECTLOWER/ $PROJECT/

  echo "Category: $THEME"
  echo "Project: $PROJECT"
  echo "Name \"package.json\": $PROJECTLOWER"

  eval cd $PROJECT
  npm install

  rm ./src/App.tsx
  touch ./src/App.tsx
  file_builder "
    import './App.css'
    import * as pack from '../package.json'

    export default function App() {
      return (
        <div className='App'>
          <h1>App: {pack.name}</h1>
        </div>
      )
    }
  " ./src/App.tsx
  
  REPLACEDEV=$(awk '{sub(/"dev"/,"\"start\"")}1' package.json)
  echo "$REPLACEDEV" > package.json

  rm ./src/App.css
  touch ./src/App.css

  rm ./src/index.css
  touch ./src/index.css
  
  SUM=$(( 53 - (${#THEME} + ${#PROJECT} + 1) ))
  OFFSETTER=$(printf "%-${SUM}s")

  clear
  echo "¸_____________________________________________________________¸"
  echo "|        .                                         +          |"
  echo "|                 --- Happy TSX Scripting ---            ¤    |"
  echo "|   *       ¤                                 °               |"
  echo "|¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨|"
  echo "| Run the following to get started:                           |"
  echo "| ∙ cd ./${THEME}/${PROJECT}${OFFSETTER// / }|"
  echo "| ∙ npm run start                                             |"
  echo "|                                                             |"
  echo "| Important files...                                          |"
  echo "| ∙ src/App.tsx: (React/TSX code)                             |"
  echo "| ∙ src/App.css: (Styles)                                     |"
  echo "| ∙ tsconfig.json: (TypeScript config settings)               |"
  echo "|_____________________________________________________________|"
  echo "| ::                   --- Resources ---                   :: |"
  echo "|¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨|"
  echo "| Documentation...                                            |"
  echo "| ∙ React/TypeScript:                                         |"
  echo "|   ∙ https://www.typescriptlang.org/docs/                    |"
  echo "|   ∙ https://reactjs.org/docs/getting-started.html           |"
  echo "|   ∙ https://www.typescriptlang.org/docs/handbook/react.html |"
  echo "|                                                             |"
  echo "| Cheat sheets:                                               |"
  echo "| ∙ https://github.com/typescript-cheatsheets/react           |"
  echo "|                                                             |"
  echo "| Tutorial: https://www.youtube.com/watch?v=BwuLxPH8IDs       |"
  echo "!_____________________________________________________________!"
fi