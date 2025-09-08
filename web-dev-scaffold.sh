#!/bin/bash

BLUE='\033[0;34m'
NOCOLOR='\033[0m'

#-----------------------------------------
#-----------------------------------------
# get project name
read -p "Enter project name: " projectName

echo -e "${BLUE}Creating ${projectName}${NOCOLOR}"

#-----------------------------------------
#-----------------------------------------
# create directories
echo -e "${BLUE}creating directories${NOCOLOR}"

mkdir "${projectName}"
cd "${projectName}/"

mkdir cmd
mkdir cmd/data_store
mkdir cmd/service
mkdir cmd/repository
mkdir cmd/handler
mkdir cmd/entity
mkdir cmd/components
mkdir cmd/components/shared

mkdir static
mkdir static/styles
mkdir static/scripts
mkdir db
mkdir config

echo -e "${BLUE}directories created!${NOCOLOR}"
#-----------------------------------------
#-----------------------------------------
# install tools
echo -e "${BLUE}installing tools${NOCOLOR}"

go mod init "example.com/${projectName}"

# GORM
go get gorm.io/gorm
go get gorm.io/driver/sqlite

# echo -e web framework
go get github.com/labstack/echo/v4
go get github.com/labstack/echo/v4/middleware

# environment variables
go get github.com/caarlos0/env/v11

# Gomponents
go get maragu.dev/gomponents

# Tailwind
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
chmod +x tailwindcss-linux-x64
mv tailwindcss-linux-x64 tailwindcss

# AIR live reload
go install github.com/air-verse/air@latest

# Flowbite UI
wget https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.css -P ./static/styles
wget https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.min.js -P ./static/scripts

# HTMX
wget https://unpkg.com/htmx.org@2.0.6/dist/htmx.min.js -P ./static/scripts

echo -e "${BLUE}tools installed!"
#-----------------------------------------
#-----------------------------------------
# create files
echo -e "${BLUE}creating files${NOCOLOR}"

{
  # environment variables
  cat >.env <<EOF
DATABASE_URL=
EOF

  # tailwind styles file for editing
  cat >input.css <<END
@tailwind base;
@tailwind components;
@tailwind utilities;
END

  # dev-server
  cat >makefile <<END
style-watcher:
	./tailwindcss -i ./input.css -o ./static/styles/output.css --watch

dev-server:
	cd cmd/; \
	air
END

  # tailwind config
  cat >tailwind.config.js <<END
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./cmd/components/**/*.go",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
END

  # main.go
  cat >cmd/main.go <<EOF
package main

import (
	"example.com/${projectName}/cmd/components/shared"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"example.com/${projectName}/config"
)

func main() {
	// initialize config
	cfg, err := config.Get()
	if err != nil {
	  panic(err.Error())
	}

	// initialize database
	_, err = InitializeDatabase(cfg.DatabaseUrl)
	if err != nil {
		panic(err.Error())
	}

	// initalize router
	e := echo.New()
	e.Use(middleware.RequestID())
	e.Use(middleware.Logger())
	e.GET("/", func(c echo.Context) error {
		return shared.Page("Welcome!", shared.SampleBody()).Render(c.Response())
	})
	e.Static("/static", "../static")
	e.Logger.Fatal(e.Start(":5000"))
}
EOF

  # database
  cat >cmd/db.go <<END
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
  cat >cmd/components/shared/page.go <<END
package shared

import (
	g "maragu.dev/gomponents"
	c "maragu.dev/gomponents/components"
	. "maragu.dev/gomponents/html"
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

cat >config/config.go << END
package config

import (
	"github.com/caarlos0/env/v11"
)

type Config struct {
  DatabaseUrl string `env:"DATABASE_URL"`
}

func Get() (*Config, error) {
  var cfg Config
  err := env.Parse(&cfg)
  if err != nil {
    return nil, err
  }
  return &cfg, nil
}
END

  # sync go modules
  go mod vendor

} &>/dev/null

echo -e "${BLUE}files created!"
#-----------------------------------------
#-----------------------------------------
echo -e "${BLUE}initializing git${NOCOLOR}"
{
  # initialize git
  git init
  cat >.gitignore <<EOF
.env
tailwindcss
EOF
} &>/dev/null
echo -e "${BLUE}git initialized!"

echo -e "${BLUE}Project is ready at ${projectName}/ !"
