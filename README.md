
# Project Title: D&D OldSchool

**Integrante:** Ivonne Santander soto

**Asignatura:** Programación de Dispositivos Móviles

**Matricula:** 2019479010

D&D OldSchool es una aplicación móvil desarrollada con Flutter que funciona como en organiza información de las ediciones clásicas de Dungeons & Dragons (desde OD&D, AD&D 1e y 2e, hasta 3.5e, excluyendo la 5e).
Permitirá explorar:

 - Reglas antiguas organizadas.
 
 - Descripciones de monstruos, razas y personajes clásicos.

 - Módulos de aventuras antiguas.

 - Material de ambientación (universo, deidades, aleaciones, objetos mágicos).

El objetivo es entregar una experiencia wiki-nostálgica para jugadores que quieran revivir la vieja escuela de D&D.

## Funcionalidades implementadas 
- **Splash Screen** con logo de D&D.  
- **Home Page** con bienvenida y acceso rápido.  
- **Menú de navegación** con secciones principales.  
- **Vista de lista y detalle** para explorar monstruos y ediciones.  
- **Uso de assets gráficos** (logo retro, imágenes de monstruos).  
- **Tema visual retro** con colores pergamino y marrones.  

## Tecnologías utilizadas

### **Frontend**
- Flutter **3.x**
- Dart
- Material Design 3
- Widgets personalizados (Card, ListTile, ListView.builder, ExpansionTile)
- **Navigator 2.0** para navegación por rutas
- **flutter_svg** para íconos SVG
- **provider** para manejo de estado global

### **Backend local**
- **SQFLite** para persistencia de datos
- **Path Provider** (almacenamiento de imágenes locales)
- **Shared Preferences** (configuraciones del usuario)

### **Integración externa**
- **D&D 5e API** (https://www.dnd5eapi.co/)
- **HTTP Client** para consumo de API
- Sistema propio de **sincronización con progreso** (SyncService)
- **ImageDownloader** para descargar imágenes desde múltiples fuentes

---

## ⚙️ Características principales

- 📥 **Sincronización completa** desde D&D 5e API  
  Monsters, Spells, Races, Classes, Equipment

- 💾 **Modo Offline**  
  Todo se guarda en SQLite (consultable sin internet)

- ⭐ Favoritos en:
  - Monstruos  
  - Hechizos  
  - Razas  
  - Equipo  

- 🔍 Búsqueda + Filtros  
  - Filtros por nivel, escuela, edición, tipo, tamaño  
  - Buscador en listas

- 🎨 Tema visual configurable  
  - Tema claro / oscuro  
  - Colores basados en Material You

- 📦 Descarga de imágenes  
  - Descarga automática por nombre  
  - Almacenamiento local  
  - Cacheo para evitar redescargas

---


## ▶️ Instalación y ejecución


flutter pub get
flutter run

## Estructura básica del proyecto
dnd_oldschool/
│
├── lib/
│ ├── main.dart
│ ├── app_router.dart
│ │
│ ├── pages/
│ │ ├── home_page.dart
│ │ ├── monsters_list_page.dart
│ │ ├── monster_detail_page.dart
│ │ ├── spells_list_page.dart
│ │ ├── races_page.dart
│ │ ├── classes_page.dart
│ │ ├── equipment_page.dart
│ │ └── settings_page.dart
│ │
│ ├── models/
│ │ ├── monster.dart
│ │ ├── spell.dart
│ │ ├── race.dart
│ │ ├── character_class.dart
│ │ └── equipment.dart
│ │
│ ├── services/
│ │ ├── api_service.dart
│ │ ├── sync_service.dart
│ │ ├── database_helper.dart
│ │ ├── image_downloader.dart
│ │ └── prefs_service.dart
│ │
│ ├── providers/
│ │ ├── monster_provider.dart
│ │ ├── theme_provider.dart
│ │ └── navigation_provider.dart
│ │
│ ├── theme/
│ │ ├── app_theme.dart
│ │ └── color_schemes.g.dart
│ │
│ └── utils/
│ └── helpers.dart
│
├── assets/
│ ├── icons/
│ ├── images/
│ └── fonts/
│
└── pubspec.yaml
