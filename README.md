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
* Jesus Moreno Moreno - [https://github.com/jmoreno220](https://github.com/jmoreno220)

---

## b. Consideraciones de seguridad hechas durante el diseño

Durante el diseño de la arquitectura (S-SDLC), se evaluaron e implementaron las siguientes medidas:
* **Prevención de Inyecciones SQL:** El acceso a datos en `src/persistence/sqlite.js` y `mysql.js` se ha planteado utilizando consultas preparadas o parametrizadas.
* **Seguridad del Contenedor:** Se implementó una imagen base `alpine` (reducida) y se configuró el `Dockerfile` para usar el usuario no privilegiado `node`, mitigando el impacto de una posible brecha.
* **Prevención de Fuga de Datos:** Se creó un archivo `.dockerignore` para garantizar que los archivos de las carpetas `tests/` y `spec/` no se incluyan en el artefacto final de producción.

---

## c. Paso a paso: Creación siguiendo S-SDLC y DevSecOps

1. **Planificación y Requisitos:** Definición de la necesidad de una aplicación To-Do resistente a inyecciones y con dependencias seguras.
2. **Desarrollo (Commit):** El código se desarrolla en Node.js. Al hacer un commit/push, el código viaja a GitHub.
3. **Integración Continua (SCA):** GitHub Actions intercepta el *push* y ejecuta `npm audit`. Si detecta vulnerabilidades críticas en `package.json`, bloquea el pipeline.
4. **Construcción Inmutable:** Si el código es seguro, el pipeline construye automáticamente la imagen de Docker asegurando que las dependencias instaladas sean exactamente las de producción (`npm ci --only=production`).
5. **Despliegue:** La imagen resultante está lista para ser desplegada en un servidor.

---

## d. Actividad 3: Evaluación y Monitorización de la Seguridad del Código

En esta fase del proyecto, nos enfocamos en validar la seguridad del código mediante técnicas de análisis estático, dinámico y de composición. Para demostrar la efectividad de las herramientas seleccionadas y ganar experiencia en la interpretación de alertas, **se ha alterado intencionalmente la aplicación introduciendo fallos críticos de seguridad** en el código fuente, dependencias y configuración.

### 1. Herramientas y Técnicas de Seguridad Seleccionadas

Para este entorno basado en Node.js y Docker, se utilizaron las siguientes cinco herramientas:

1. **Análisis de Composición de Software (SCA) - GitHub Dependabot / `npm audit`**
   * *Justificación:* Al depender del ecosistema `npm`, es vital monitorear vulnerabilidades conocidas (CVEs) en librerías de terceros para evitar ataques a la cadena de suministro.
2. **Pruebas de Seguridad de Aplicaciones Estáticas (SAST) - GitHub CodeQL**
   * *Justificación:* Escanea el flujo de datos de JavaScript/Node.js en busca de patrones vulnerables sin ejecutar la app. Se integra en GitHub Actions para evaluar el código automatizadamente.
3. **Escaneo de Secretos (Secret Scanning) - GitHub Secret Scanning**
   * *Justificación:* Detecta de forma nativa si se han persistido credenciales en texto plano (como tokens de APIs) en el repositorio o en archivos como el `Dockerfile`.
4. **Análisis Estático Local (Linter) - ESLint + `eslint-plugin-security`**
   * *Justificación:* Aplica el principio de *Shift-Left*, proporcionando un mecanismo de *fail-fast* en el entorno local del desarrollador antes de realizar un commit.
5. **Pruebas de Seguridad de Aplicaciones Dinámicas (DAST) - OWASP ZAP (Zed Attack Proxy)**
   * *Justificación:* Evalúa la aplicación To-Do en tiempo de ejecución dentro del contenedor Docker simulando ataques reales en busca de fallos lógicos o configuraciones inseguras de cabeceras HTTP.

### 2. Historial de Alteraciones (Inyección de Fallos)

Para forzar a las herramientas a reportar alertas, se realizaron las siguientes modificaciones intencionales:

| Modificación Realizada | Archivo Afectado | Herramienta Objetivo | Efecto Buscado |
| :--- | :--- | :--- | :--- |
| **Degradación de versión de dependencia** | `app/package.json` | SCA (Dependabot / `npm audit`) | Disparar una alerta crítica instalando una versión antigua de `lodash` (4.17.15) vulnerable a *Prototype Pollution*. |
| **Inyección SQL directa** | `app/src/persistence/sqlite.js` | SAST (GitHub CodeQL) | Romper el uso de consultas parametrizadas concatenando variables directamente en la consulta `INSERT`, para que CodeQL trace el fallo. |
| **Credenciales expuestas** | `app/Dockerfile` | Secret Scanning | Añadir variables de entorno ficticias (`AWS_ACCESS_KEY_ID`) en texto plano para verificar la detección y bloqueo del repositorio. |
| **Uso de funciones inseguras** | Controlador de rutas | Linter (ESLint) | Introducir la función `eval()` procesando variables arbitrarias para observar el bloqueo en la compilación local. |
| **Falta de sanitización de salida** | Vistas del Frontend | DAST (OWASP ZAP) | Deshabilitar el escape de caracteres al mostrar el nombre de una tarea, permitiendo la ejecución de un script en el cliente. |

### 3. Reporte de Resultados de la Evaluación

Tras ejecutar la batería de pruebas, se registraron las siguientes alertas y resultados:

* **Reporte de Análisis SCA (`npm audit` / Dependabot)**
  * **Alerta:** `Critical Severity Vulnerability - Prototype Pollution in lodash`.
  * **Resultado:** La ejecución local de `npm audit` marcó el fallo. En el repositorio, Dependabot bloqueó el estado de seguridad y generó automáticamente un *Pull Request* sugiriendo la actualización a una versión segura de la librería.

* **Reporte de Análisis SAST (GitHub CodeQL)**
  * **Alerta:** `Database query built from user-controlled sources (CWE-89: SQL Injection)`.
  * **Resultado:** Severidad Alta. El análisis en la pestaña *Security* trazó el flujo de datos desde el endpoint de Express hasta el motor SQLite, confirmando la vulnerabilidad por concatenación de *strings*.

* **Reporte de Escaneo de Secretos (GitHub)**
  * **Alerta:** `Secret Detected: AWS Access Key ID`.
  * **Resultado:** GitHub detectó el formato del token expuesto en el `Dockerfile` de forma inmediata tras el *push*, demostrando cómo se previenen fugas de credenciales en repositorios públicos.

* **Reporte de Análisis Dinámico (OWASP ZAP)**
  * **Alerta:** `Cross-Site Scripting (Reflected) - CWE-79` y `X-Content-Type-Options Header Missing`.
  * **Resultado:** Al lanzar un ataque automatizado contra el contenedor activo en el puerto 3000, ZAP logró inyectar y ejecutar un *payload* de JavaScript (`<script>`) a través del formulario de creación de tareas.

* **Reporte del Linter Local (ESLint)**
  * **Alerta:** `eslint(security/detect-eval-with-expression): Predictable/hazardous eval()`.
  * **Resultado:** El desarrollador recibió un error en su terminal (`npm run lint`), lo que le impidió avanzar sin antes corregir la mala práctica detectada en el código JavaScript.
