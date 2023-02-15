#!/bin/bash
ISNPM=$(command -v npm)

if [[ -z $ISNPM ]]
then
  echo "Node.js has not been installed!"
  echo "Please install Node.js from: https://nodejs.org/en/"
  echo "Exit typo.sh"
  exit 1
fi

echo "[::New TypeScript Playpen Setup::]"
echo "What is the category of the project? Give a name..."
read THEME
echo "Give a name of the TypeScript Project for ${THEME}?"
read PROJECT
PROJECTLOWER="${PROJECT,,}"

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
    echo "${THEME}: genre of project already exists!"
    echo "This script will skip to setup ${PROJECT} in the ${THEME} directory"
  else
    echo "Making [${THEME}] directory"
    mkdir $THEME
  fi

  echo "Making the project: [${PROJECT}]"
  mkdir $THEME/$PROJECT/

  echo "Category: $THEME"
  echo "Project: $PROJECT"
  echo "Name \"package.json\": $PROJECTLOWER"

  eval cd $THEME/$PROJECT
  npm init -y
  npm install webpack webpack-cli typescript ts-loader npm-run-all live-server --save-dev
  
  mkdir src

  touch ./src/index.ts
  file_builder '
    const button = document.querySelector(".button")! as HTMLInputElement;
    const input1 = document.querySelector(".math1")! as HTMLInputElement;
    const input2 = document.querySelector(".math2")! as HTMLInputElement;
    const output = document.querySelector(".scripting")! as HTMLElement;

    button.addEventListener("click", () => {
      output.textContent = (+input1.value + +input2.value).toString();
    })
  ' ./src/index.ts

  mkdir dist

  touch ./dist/index.html
  file_builder '
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content=""width=device-width, initial-scale="1.0" />
        <meta http-equiv="X-UA-Compatible" content="ie=edge" />
        <link rel="stylesheet" href="style.css" />
        <title>TypeScripting</title>
      </head>
      <body>
        <h1 class="intro">This is a Heading</h1>
        <p class="subheading">This is a paragraph.</p>
        <div class="inputs">1st #: <input type="number" class="math1" /></div>
        <div class="inputs">2nd #: <input type="number" class="math2" /></div>
        <div class="button">Calculate Sum</div>
        <p class="scripting"></p>
        <script src="bundle.js"></script>
      </body>
    </html>
  ' ./dist/index.html

  touch ./dist/style.css
  file_builder '
    body {
      font-family: Helvetica, Arial, sans-serif;
      color: #eeeeee;
      background-color: #222;
    }

    .button {
      color: orange;
      background-color: maroon;
      width: 150px;
      cursor: pointer;
    }

    .button:active {
      color: maroon;
      background-color: orange;
      width: 150px;
      cursor: pointer;
    }

    .inputs {
      font-family: monospace, monospace;
    }
  ' ./dist/style.css

  touch tsconfig.json
  file_builder '
    {
      "compilerOptions": {
        "noImplicitAny": true,
        "strictNullChecks": true,
        "strictFunctionTypes": true,
        "noImplicitThis": true,
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "target": "ES2020",
        "sourceMap": true,
        "outDir": "./dist/"
      },
      "include": ["src/**/*"]
    }
  ' tsconfig.json

  touch webpack.config.js
  file_builder '
    import path from "path";
    import { fileURLToPath } from "url";

    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);

    export default {
      mode: "development",
      entry: "./src/index.ts",
      devtool: "inline-source-map",
      module: {
        rules: [
          {
            test: /\.tsx?$/,
            use: "ts-loader",
            exclude: /node_modules/,
          },
        ],
      },
      resolve: {
        extensions: [".tsx", ".ts", ".js"],
      },
      output: {
        filename: "bundle.js",
        path: path.resolve(__dirname, "dist"),
      },
    };
  ' webpack.config.js

  # awk '1;/PATTERN/{ print "add one line"; print "\\and one more"}' file.txt > filet.txt
  AWKI=$(awk '1;/"name":/{ print "  \"type\": \"module\",";}' package.json)
  echo "$AWKI" > package.json
  # # sed -i '/\"name\":/a \ \ \"type\": \"module\",' package.json
  AWKI=$(awk -F: '/"test": "echo/{ $0=$0 "," }1' package.json)
  echo "$AWKI" > package.json
  # sed -i '/\"test\": \"echo/ s/$/,/' package.json

  # sed -i '/\"test\":\ "echo/a \ \ \ \ \"start\": \"npm run bundle && npm-run-all --parallel watch serve\",' package.json
  # sed -i '/\"start\": \"npm run/a \ \ \ \ \"bundle\": \"webpack\",' package.json
  # sed -i '/\"bundle\": \"webpack\"/a \ \ \ \ \"watch\": \"webpack --watch\",' package.json
  # sed -i '/\"watch\": \"webpack --watch\"/a \ \ \ \ \"serve\": \"cd dist && live-server\"' package.json

  AWKI=$(awk '1;/"test": "echo/{ 
    print "    \"start\": \"npm run bundle && npm-run-all --parallel watch serve\",";
    print "    \"bundle\": \"webpack\",";
    print "    \"watch\": \"webpack --watch\",";
    print "    \"serve\": \"cd dist && live-server\"";
  }' package.json)
  echo "$AWKI" > package.json

  SUM=$(( 50 - (${#THEME} + ${#PROJECT} + 1) ))
  OFFSETTER=$(printf "%-${SUM}s")
  
  clear
  echo "¸__________________________________________________________¸"
  echo "|        .                                      +          |"
  echo "|               --- Happy TypeScripting! ---           ¤   |"
  echo "|   *       ¤                                 °            |"
  echo "|¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨|"
  echo "| Run the following to get started:                        |"
  echo "| ∙ cd ./${THEME}/${PROJECT}${OFFSETTER// / }|"
  echo "| ∙ npm run start                                          |"
  echo "|                                                          |"
  echo "| Important files...                                       |"
  echo "| ∙ src/index.ts: (TypeScript code)                        |"
  echo "| ∙ dist/index.html: (HTML)                                |"
  echo "| ∙ dist/style.css: (Styles)                               |"
  echo "| ∙ tsconfig.json: (TypeScript config settings)            |"
  echo "|__________________________________________________________|"
  echo "| ::                 --- Resources! ---                 :: |"
  echo "|¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨|"
  echo "| Documentation: https://www.typescriptlang.org/docs/      |"
  echo "| Cheat sheets: https://www.typescriptlang.org/cheatsheets |"
  echo "| Tutorial: https://www.youtube.com/watch?v=BwuLxPH8IDs    |"
  echo "!__________________________________________________________!"
fi