# Web Dev Scaffold 

A straightforward bash script that makes it easy for me (and anyone else who wants) to spin up a new web development project in Go.

## Why is this needed?
I like building web applications in Go, but my tooling choices never really aligned with an existing "batteries included" style framework. However, I do have some favorite tools that I tend to reach for often, and I wanted to automate away some of the boilerplate project creation and configuration that saps my enthusiasm when diving into a new project. 

You don't have to use this script. You may disagree with one, many, or all of my technology choices, and that's totally fine. However, if you haven't yet automated your project setup, maybe this can provide a little inspiration.

## What's in the stack (tools)
- [Go programming language](https://go.dev/) 
  - this scaffold assumes you already have go installed on your system
- [GORM](https://gorm.io/docs/index.html)
  - bring your own database
- [Echo Framework](https://github.com/labstack/echo)
  - handy Go web framework
- [Gomponents](https://www.gomponents.com/)
  - I prefer this over TEMPL currently, as it doesn't need a separate compiler, and the Go LSP in IntelliJ treats it like any other Go code.
- [TailwindCSS](https://tailwindcss.com/blog/standalone-cli)
  - I want to limit my Javascript exposure; the Standalone CLI lets me avoid a package.json and other node artifacts in my project
- [FlowbiteUI](https://flowbite.com/docs/getting-started/quickstart/)
  - The free version is pretty good, and covers most of my use cases
- [HTMX](https://htmx.org/)
  - I prefer an HTMX first approach, when it makes sense to do so.
- [Air](https://github.com/air-verse/air)
  - makes it faster to rebuild app on changes and view them quickly in the browser

## Methodologies
- Domain Driven Design
  - I am still a noob in this area, but I've found some of the concepts helpful to keep in mind as I approach my projects' architecture.
- Test Driven Development
  - I'm still working the hate out of my love / hate relationship with TDD, but it just keeps helping me more and more over time, and I want to stick with it.

## How to use
1. Clone the repo
2. make the script executable
```shell
chmod +x web-dev-scaffold.sh
```
3. Execute the script
```shell
./web-dev-scaffold.sh
```
4. Type in a name for your project
5. The script creates a scaffold for your project, and you're ready to go!