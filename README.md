# MRRichar App

Aplicacion Flutter para seguimiento de campeonatos, rankings y partidos.

## Resumen

La app permite:

- Seleccionar un jugador por defecto en configuracion.
- Ver el inicio personalizado con resumen del jugador.
- Consultar rankings de comunidad y campeonatos.
- Explorar campeonatos por grupos y fase eliminatoria.
- Abrir detalle de partidos con fecha/ventana de tiempo cuando existe.

## Datos y sincronizacion

La fuente de datos es un archivo Excel (XLSX):

1. Al iniciar, la app intenta sincronizar desde Google Sheets.
2. Si la descarga es exitosa, guarda una copia local en el dispositivo.
3. La lectura se hace primero desde la copia local.
4. Si no hay copia local valida, usa el archivo incluido en assets.

URL de sincronizacion actual:

- https://docs.google.com/spreadsheets/d/1wFG-BvNw3XdA96mGC0DGO1Zm_wl-hvGO/export?format=xlsx

Implementacion:

- [lib/data/excel_data_source.dart](lib/data/excel_data_source.dart)

## Recursos visuales

- El logo principal de la app y el fondo global se cargan desde assets locales.
- No se descargan desde internet en runtime.
- Si un logo de jugador/torneo no existe o falla, se usa fallback visual.

Implementacion:

- [lib/data/app_image_cache.dart](lib/data/app_image_cache.dart)

## Estructura principal

- [lib/main.dart](lib/main.dart): arranque, bootstrap y navegacion principal.
- [lib/features/dashboard/dashboard_page.dart](lib/features/dashboard/dashboard_page.dart): inicio.
- [lib/features/rankings/rankings_page.dart](lib/features/rankings/rankings_page.dart): rankings y detalle.
- [lib/features/championships/championships_page.dart](lib/features/championships/championships_page.dart): campeonatos, grupos y eliminacion.
- [lib/features/matches/matches_page.dart](lib/features/matches/matches_page.dart): partidos y detalle.
- [lib/features/settings/settings_page.dart](lib/features/settings/settings_page.dart): jugador por defecto.
- [lib/data/local_settings_db.dart](lib/data/local_settings_db.dart): persistencia local de ajustes.

## Ejecutar en local

Requisitos:

- Flutter SDK instalado.
- Dispositivo Android/emulador o plataforma de escritorio compatible.

Comandos:

```bash
flutter pub get
flutter run
```

## Generar el Excel de ejemplo

Script principal:

- [tool/generate_excel.dart](tool/generate_excel.dart)

Desde la carpeta scripts:

```powershell
.\generate_excel.bat
```

Archivo generado:

- assets/data/mrrichar_data.xlsx

## Publicacion

- Politica de privacidad: [privacy.html](privacy.html)
- Permiso de red Android: [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)

## Build release

```bash
flutter build appbundle
```
