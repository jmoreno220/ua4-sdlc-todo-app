# To-Do Web-App: Proyecto DevSecOps

## a. Definición de la aplicación y cómo ejecutarla
La presente aplicación es una Web-App de gestión de tareas (To-Do) construida con Node.js en el backend, permitiendo la persistencia de datos mediante SQLite/MySQL. Se ha contenerizado con Docker para asegurar entornos inmutables.

**Ejecución:**
1. Clonar este repositorio.
2. Navegar a la carpeta `app/`.
3. Construir la imagen: `docker build -t todo-app-sec .`
4. Ejecutar el contenedor: `docker run -d -p 3000:3000 todo-app-sec`
5. Acceder a `http://localhost:3000`.

**Miembros del proyecto y repositorios previos:**
* Jesus Moreno Moreno - (https://github.com/jmoreno220)

## b. Consideraciones de seguridad hechas durante el diseño
Durante el diseño de la arquitectura (S-SDLC), se evaluaron e implementaron las siguientes medidas:
* **Prevención de Inyecciones SQL:** El acceso a datos en `src/persistence/sqlite.js` y `mysql.js` se ha planteado utilizando consultas preparadas o parametrizadas.
* **Seguridad del Contenedor:** Se implementó una imagen base `alpine` (reducida) y se configuró el `Dockerfile` para usar el usuario no privilegiado `node`, mitigando el impacto de una posible brecha.
* **Prevención de Fuga de Datos:** Se creó un archivo `.dockerignore` para garantizar que los archivos de las carpetas `tests/` y `spec/` no se incluyan en el artefacto final de producción.

## c. Paso a paso: Creación siguiendo S-SDLC y DevSecOps
1. **Planificación y Requisitos:** Definición de la necesidad de una aplicación To-Do resistente a inyecciones y con dependencias seguras.
2. **Desarrollo (Commit):** El código se desarrolla en Node.js. Al hacer un commit/push, el código viaja a GitHub.
3. **Integración Continua (SCA):** GitHub Actions intercepta el *push* y ejecuta `npm audit`. Si detecta vulnerabilidades críticas en `package.json`, bloquea el pipeline.
4. **Construcción Inmutable:** Si el código es seguro, el pipeline construye automáticamente la imagen de Docker asegurando que las dependencias instaladas sean exactamente las de producción (`npm ci --only=production`).
5. **Despliegue:** La imagen resultante está lista para ser desplegada en un servidor.