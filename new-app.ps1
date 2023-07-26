param($arg1)
$dirName = $arg1.Substring(0, 1).ToLower() + $arg1.Substring(1)
$projName = $arg1.Substring(0, 1).ToUpper() + $arg1.Substring(1)

new-item -path ./$dirName -itemtype directory
cd ./$dirName

npm install -g gitignore
gitignore VisualStudio

# $response = Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/react"

# Add-Content -Path ".gitignore" -Value "$response"


git init





dotnet new sln -n $projName

dotnet new webapi --framework net6.0 --output $dirName --name $projName
dotnet sln add "$dirName/$projName.csproj"

$testPath = $dirName + "Tests"
$testName = $projName + "Tests"
dotnet new nunit --framework net6.0 --output $testPath --name $testName
dotnet sln add "$testPath/$testName.csproj"

npm create-react-app "$dirNameClient" --template typescript

git add ./*
git commit -m "init .net 6 proj"
cd ..