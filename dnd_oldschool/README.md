
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

- Flutter 3.x

- Dart

- Material Design

- Navigator para navegación

- Widgets personalizados (Card, ListView.builder, SvgPicture)

- flutter_svg para iconos en formato SVG

## Estructura básica del proyecto
lib/
├─ main.dart
├─ app_router.dart
├─ models/
│ └─ monster.dart
├─ pages/
│ ├─ splash_page.dart
│ ├─ home_page.dart
│ ├─ editions_page.dart
│ ├─ monsters_list_page.dart
│ └─ monster_detail_page.dart
└─ widgets/
└─ simple_card.dart
