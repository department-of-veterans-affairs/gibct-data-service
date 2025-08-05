// FIXME: es-module-shim won't shim the dynamic import without this explicit import
import "@hotwired/stimulus"

const controllerAttribute = "data-controller"

export function eagerLoadControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path =>
    path.match(new RegExp(`^${under}/.*_controller$`))
  )

  paths.forEach(path => registerControllerFromPath(path, under, application))
}

function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").text).imports
}

function registerControllerFromPath(path, under, application) {
  const name = path
    .replace(new RegExp(`^${under}/`), "")
    .replace("_controller", "")
    .replace(/\//g, "--")
    .replace(/_/g, "-")

  if (canRegisterController(name, application)) {
    import(path)
      .then(module => registerController(name, module, application))
      .catch(error => {
        if (error instanceof TypeError) {
          error.message = `Failed to register controller: ${name} (${path})`
        }

        throw error
      })
  }
}

function registerController(name, module, application) {
  if (canRegisterController(name, application)) {
    application.register(name, module.default)
  }
}

function canRegisterController(name, application) {
  return !application.router.modulesByIdentifier.has(name)
}
