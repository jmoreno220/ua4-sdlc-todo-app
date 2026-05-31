#!/bin/bash
echo "=== INICIANDO PRUEBAS DE SEGURIDAD (LÍNEA BASE) ==="

echo "1. Construyendo la imagen de la aplicación (Baseline)..."
cd ..\app
docker build -t todo-app-baseline .

echo "2. Ejecutando análisis estático básico de dependencias (SCA)..."
# Usamos Docker para lanzar yarn audit sin instalar Node en tu Windows
docker run --rm -v "${PWD}:/app" -w /app node:18 yarn audit > ../tests/vulnerabilidades_iniciales.txt || echo "Auditoría completada con hallazgos."

echo "=== PRUEBAS FINALIZADAS ==="
echo "Revisa 'tests/vulnerabilidades_iniciales.txt'. Estos hallazgos se mitigarán en futuras iteraciones del S-SDLC."