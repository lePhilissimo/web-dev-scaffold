#!/bin/bash

#-----------------------------------------
#-----------------------------------------
# get project name
read -p "Enter project name: " projectName

echo "Creating ${projectName}"


#-----------------------------------------
#-----------------------------------------
# create directories
{
mkdir "${projectName}"
cd "${projectName}/"

mkdir cmd
mkdir cmd/api
mkdir cmd/api/domain
mkdir cmd/api/domain/data_store
mkdir cmd/api/domain/service
mkdir cmd/api/domain/repository
mkdir cmd/api/domain/handler
mkdir cmd/api/domain/entity
mkdir cmd/api/domain/components
mkdir cmd/api/domain/components/shared

mkdir static
mkdir static/styles
mkdir static/scripts
mkdir db
} &> /dev/null
echo "directories created"
#-----------------------------------------
#-----------------------------------------
# install tools
{
go mod init "example.com/${projectName}"

# GORM
go get -u gorm.io/gorm
go get -u gorm.io/driver/sqlite

# Echo web framework
go get github.com/labstack/echo/v4

# Gomponents
go get github.com/maragudk/gomponents

# Tailwind
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
mv tailwindcss-linux-x64 tailwindcss

# AIR live reload
go install github.com/air-verse/air@latest

# Flowbite UI
wget https://cdn.jsdelivr.net/npm/flowbite@2.5.1/dist/flowbite.min.css -P ./static/styles
wget https://cdn.jsdelivr.net/npm/flowbite@2.5.1/dist/flowbite.min.js -P ./static/scripts

# HTMX
wget https://unpkg.com/htmx.org@2.0.2/dist/htmx.min.js -P ./static/scripts


} &> /dev/null
echo "tools installed"
#-----------------------------------------
#-----------------------------------------
# create files
{
# environment variables
cat > .env << EOF
DATABASE_URL=
EOF

# tailwind styles file for editing
cat > input.css << END
@tailwind base;
@tailwind components;
@tailwind utilities;
END

# dev-server
cat > makefile << END
style-watcher:
	./tailwindcss -i ./input.css -o ./static/styles/output.css --watch

dev-server:
	cd cmd/; \
	air
END

# tailwind config
cat > tailwind.config.js << END
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./cmd/api/domain/components/**/*.go",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
END

# main.go
cat > cmd/main.go << EOF
package main

import (
	"example.com/${projectName}/cmd/api/domain/components/shared"
	"github.com/labstack/echo/v4"
)

func main() {
	// initialize config

	// initialize database
	_, err := InitializeDatabase("")
	if err != nil {
		panic(err.Error())
	}

	// initalize router
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return shared.Page("Welcome!", shared.SampleBody()).Render(c.Response())
	})
	e.Static("/static", "../static")
	e.Logger.Fatal(e.Start(":5000"))
}
EOF

# database
cat > cmd/db.go << END
package main

import (
	"gorm.io/driver/sqlite" // Sqlite driver based on CGO
	"gorm.io/gorm"
)

func InitializeDatabase(dsn string) (*gorm.DB, error) {
	return gorm.Open(sqlite.Open("../db/gorm.db"), &gorm.Config{})
}
END

# shared page component
cat > cmd/api/domain/components/shared/shared.go << END
package shared

import (
	g "github.com/maragudk/gomponents"
	c "github.com/maragudk/gomponents/components"
	. "github.com/maragudk/gomponents/html"
)

func Page(title string, body g.Node) g.Node {
	// HTML5 boilerplate document
	return c.HTML5(c.HTML5Props{
		Title:    title,
		Language: "en",
		Head: []g.Node{
			Script(Src("/static/scripts/htmx.min.js")),
			Link(Rel("stylesheet"), Href("/static/styles/flowbite.min.css")),
			Link(Rel("stylesheet"), Href("/static/styles/output.css")),
			Style(".smooth{transition: all 1s ease-in}"),
		},

		Body: []g.Node{
			body,
			Script(Src("/static/scripts/flowbite.min.js")),
		},
	})
}

func SampleBody() g.Node {
  return H1(
    Class("text-2xl"),
    g.Text("Welcome to your next web dev project!"),
  )
}
END

# sync go modules
go mod vendor


} &> /dev/null

echo "files created"
#-----------------------------------------
#-----------------------------------------
{
# initialize git
git init
cat > .gitignore << EOF
.env
tailwindcss
EOF
} &> /dev/null
echo "git initialized"

echo "Project is ready at ${projectName}/"
