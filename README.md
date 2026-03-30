# MRRichar App

Aplicacion Flutter para gestion y seguimiento de campeonatos, rankings y partidos.

## Resumen

La app permite:

- Seleccionar un jugador por defecto para personalizar el inicio.
- Ver tablero de inicio con resumen del jugador, torneos activos y proximos encuentros.
- Consultar rankings y campeonatos.
- Navegar por fases de grupo y eliminacion.
- Ver detalles de partidos y sus ventanas de tiempo (inicio y termino).

## Fuente de datos

La app trabaja con un archivo Excel (XLSX) y usa este flujo:

1. Al iniciar, intenta descargar el Excel desde Google Sheets.
2. Guarda una copia local en el dispositivo.
3. Usa la copia local como fuente principal.
4. Si falla la descarga, usa la ultima copia local valida.
5. Si no existe copia local, usa el Excel incluido en assets.

URL actual de sincronizacion:

- `https://docs.google.com/spreadsheets/d/1wFG-BvNw3XdA96mGC0DGO1Zm_wl-hvGO/export?format=xlsx`

Implementacion principal:

- [ExcelDataSource](lib/data/excel_data_source.dart)

## Modelado y reglas

- Las tablas globales y por grupo se calculan automaticamente a partir de resultados de partidos.
- Los partidos soportan `startDate` y `endDate` (si faltan, no se muestran placeholders).
- Jugadores y campeonatos soportan `logoUrl`.

## Estructura principal

- [main.dart](lib/main.dart): arranque, pantalla de carga y bootstrap.
- [excel_data_source.dart](lib/data/excel_data_source.dart): lectura/parsing/sincronizacion de datos.
- [local_settings_db.dart](lib/data/local_settings_db.dart): configuracion local (jugador por defecto).
- [dashboard_page.dart](lib/features/dashboard/dashboard_page.dart): pantalla de inicio.
- [championships_page.dart](lib/features/championships/championships_page.dart): campeonatos y tablas.
- [matches_page.dart](lib/features/matches/matches_page.dart): listado y detalle de partidos.
- [settings_page.dart](lib/features/settings/settings_page.dart): seleccion de jugador.

## Ejecutar en local

Requisitos:

- Flutter SDK instalado.
- Dispositivo Android, emulador o escritorio compatible.

Comandos:

```bash
flutter pub get
flutter run
```

## Generar Excel de ejemplo

Script de generacion:

- [tool/generate_excel.dart](tool/generate_excel.dart)

Desde `scripts/`:

```powershell
.\generate_excel.bat
```

Salida:

- `assets/data/mrrichar_data.xlsx`

## Publicacion

- Politica de privacidad: [privacy.html](privacy.html)
- Permiso de red Android: [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)

## Notas

- La app usa cache local para imagen de fondo y logo global de app.
- Si una URL de logo por jugador/torneo falla o esta vacia, se usa fallback visual.
