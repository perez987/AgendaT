# AgendaT - Aplicación sencilla de agenda telefónica

![Plataforma](https://img.shields.io/badge/macOS-13+-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5-color=9494ff.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.2+-lavender.svg)

[README en inglés](README.md)

AgendaT es una aplicación sencilla de agenda telefónica, desarrollada con SwiftUI y diseñada para macOS 13 (Ventura) y versiones posteriores. La aplicación permite explorar, buscar y editar fácilmente los contactos de teléfono almacenados en un archivo XML.

Más que una aplicación para uso real (aunque funciona bien), debería considerarse un ejercicio para aprender SwiftUI y cómo manejar archivos XML como fuente de datos para un conjunto de datos.

<img src="Images/Main-window-es.png" width="640px">

## Características

- **Fuente de datos XML**: Las entradas de la agenda se almacenan en un archivo XML con cuatro subelementos:
	- Nombre
	- Teléfono 1 (sólo numérico)
	- Teléfono 2 (sólo numérico)
	- ID (clave numérica única, no puede ser nula)
- **Ordenación por varias columnas**: Haga clic en los encabezados de columna para ordenar por nombre, número de teléfono o ID.
	- Alternar entre orden ascendente y descendente.
	- Indicadores visuales que muestran el campo de ordenación actual y la dirección.
- **Visualización en cuadrícula**: Muestra las entradas en una cuadrícula LazyVGrid con el título "Números de teléfono".
- **Función de búsqueda**:
	- Búsqueda de texto por nombre (admite coincidencias parciales).
	- La búsqueda se aplica al pulsar el botón "Mostrar".
	- 26 botones con letras del alfabeto para filtrar por primera letra.
	- Botón "Borrar filtros" para restablecer todos los filtros y mostrar todos los registros.
- **Funciones de edición**:
	- Agregar nuevos contactos. Con identificadores autogenerados
	- Edita los contactos existentes haciendo clic en su nombre
	- Elimina contactos con el icono de la papelera (se requiere confirmación)
	- Los cambios se guardan en un archivo XML en el directorio de documentos
- **Contador de registros**: Muestra el número de registros visibles actualmente

## Almacenamiento en el directorio de documentos

Los contactos se guardan en un archivo XML:

`~/Library/Containers/perez987.AgendaT/Data/Documents/Phonebook.xml`

Puedes transferir tus datos copiando este archivo a otro equipo y ejecutando la aplicación AgendaT en él.

## Estructura del proyecto

- `AgendaTApp.swift` - Punto de entrada principal de la aplicación
- `ContentView.swift` - Vista principal de la interfaz de usuario
- `PhoneEntry.swift` - Modelo de datos para las entradas de teléfono
- `XMLParser.swift` - Funcionalidad de análisis XML
- `phonebook.xml` - Archivo de datos XML de ejemplo con entradas de teléfono

## Requisitos

- macOS 13.0 o posterior
- Xcode 15.0 o posterior
- Swift 5.0 o posterior

## Compilación

Abre `AgendaT.xcodeproj` en Xcode y compila el proyecto.
1. 
