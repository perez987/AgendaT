# AgendaT - Documentación técnica

AgendaT es una aplicación sencilla de agenda telefónica, desarrollada con SwiftUI y diseñada para macOS 13 (Ventura) y versiones posteriores. La aplicación ofrece una forma sencilla de explorar, buscar y editar contactos telefónicos almacenados en un archivo XML.

Más que una aplicación para uso real (aunque funciona bien), debería considerarse un ejercicio para aprender SwiftUI y cómo manejar archivos XML como origen para un conjunto de datos.

## Arquitectura

### Tecnologías principales

- **SwiftUI**: Framework de interfaz de usuario
- **Análisis XML**: Analizador XML nativo para el manejo de datos (framework Foundation que provee funcionalidades como almacenamiento de datos, procesado de textos, fecha y hora, etc.)
- **Compatibilidad con varios idiomas**: Sistema de traducciones integrado con detección automática de idioma.

### Estructura del proyecto

```
AgendaT/
├── AgendaTApp.swift              # Punto de entrada de la aplicación
├── AppDelegate.swift             # Delegado de la aplicación
├── AgendaT.entitlements          # Permisos y capacidades de la app
├── Assets.xcassets/              # Iconos y recursos visuales de la app
│   ├── AccentColor.colorset/
│   └── AppIcon.appiconset/
├── Models/
│   ├── FilterSortManager.swift   # Lógica de filtrado y ordenación
│   ├── LocalizationManager.swift # Detección de idioma y traducción
│   ├── PhoneEntry.swift          # Modelo de datos para registros de teléfono
│   ├── PhonebookManager.swift    # Gestión de datos de la agenda
│   └── XMLParser.swift           # Lógica de análisis XML
├── Resources/
│   ├── Phonebook.xml             # Almacenamiento de datos de los contactos
│   ├── en.lproj/                 # Idioma inglés
│   │   └── Localizable.strings
│   ├── es.lproj/                 # Idioma español
│   │   └── Localizable.strings
│   └── fr.lproj/                 # Idioma francés
│       └── Localizable.strings
└── Views/
    └── ContentView.swift         # Interfaz de usuario principal
```

## Componentes clave

### 1. Modelo de datos (PhoneEntry.swift)

La estructura `PhoneEntry` representa un contacto individual con:

- **id**: Identificador numérico único (obligatorio, no nulo)
- **name**: Nombre del contacto
- **phone1**: Número de teléfono principal (solo numérico)
- **phone2**: Número de teléfono secundario (solo numérico).

Implementa:

- `Identifiable`: Para la representación en listas/cuadrículas de SwiftUI
- `Codable`: Para la compatibilidad con la serialización JSON
- `Equatable`: Para comparar entradas de una lista.

**Nota:** Todas las propiedades son mutables (`var`) para permitir la edición.

### 2. Analizador XML (XMLParser.swift)

**Clase PhonebookXMLParser:**

- Implementa `XMLParserDelegate` para el análisis estilo SAX (en forma de secuencia)
- La clase `XMLParser` lee el contenido de un archivo XML e informa de lo que encuentra mediante `XMLParserDelegate`, no hace nada con los datos salvo informarlos.
- Analiza `phonebook.xml` con elementos `<Contact>` que contienen subelementos `<Name>`, `<Phone1>`, `<Phone2>` y `<ID>`
- Devuelve un array de objetos `PhoneEntry`
- Gestiona correctamente los datos con formato incorrecto (omite las entradas no válidas)

**Función loadPhonebookData():**

- Carga `phonebook.xml` desde el directorio de documentos del usuario (o lo copia desde el paquete de la app en la primera ejecución)
- Devuelve un array vacío si no se encuentra el archivo (a prueba de fallos)
- Ordena los contactos alfabéticamente por nombre mediante una comparación que tiene en cuenta la configuración regional y no distingue entre mayúsculas y minúsculas
- Proporciona un registro y una gestión de errores detallados:
	- Estado de carga del archivo
	- Progreso del análisis XML
	- Análisis de contactos individuales con validación de ID
	- Advertencias para contactos con datos faltantes Identificadores
	- Nombres del primer y último contacto tras la ordenación.

**Función savePhonebookData():**

- Guarda los contactos editados en el directorio de documentos del usuario (los recursos del paquete son de sólo lectura)
- Escapa los caracteres especiales XML (&, <, >, ', ") en los nombres de los contactos
- Crea XML con el formato correcto y sangría
- Devuelve el estado de éxito/error
- Proporciona un registro detallado para la depuración.

### 3. Interfaz de usuario (ContentView.swift)

**Características principales:**

- **Visualización en cuadrícula ordenable**: LazyVGrid con 4 encabezados de columna interactivos (Nombre, Teléfono 1, Teléfono 2, ID)
- **Ordenación por columna**: Haz clic en cualquier encabezado de columna para ordenar por ese campo (ascendente/descendente)
- **Indicadores de ordenación**: Iconos visuales en forma de V que muestran el campo de ordenación actual y la dirección
- **Búsqueda de texto**: Campo de texto para búsqueda parcial por nombre
- **Filtro alfabético**: 26 botones de letras (A-Z) para filtrar por primera letra
- **Filtrado combinado**: La búsqueda de texto y el filtro alfabético funcionan conjuntamente
- **Contador de registros**: Muestra el recuento de registros filtrados
- **Añadir contacto**: Botón para crear nuevos contactos
- **Editar contacto**: Hacer clic en el nombre del contacto para editarlo
- **Eliminar contacto**: Icono de papelera junto al ID de cada contacto (muestra diálogo de confirmación)
- **Diseño adaptable**: Tamaño mínimo de ventana 600x600 píxeles.

**Gestión del estado:**

- Propiedades `@State` para actualizaciones reactivas de la interfaz de usuario
- `allEntries`: Conjunto de datos completo cargado al iniciar
- `filteredEntries`: Vista actual después de aplicar filtros y ordenar
- `searchText`: Texto de búsqueda del usuario
- `selectedLetter`: Filtro de letra seleccionado actualmente
- `sortField`: Columna de ordenación actual (nombre, teléfono1, teléfono2, id)
- `sortAscending`: Indicador de dirección de ordenación
- `editingEntry`: Contacto que se está editando.

**Lógica de filtrado y ordenación:**

- Filtro de letra: Coincidencia de prefijo sin distinción entre mayúsculas y minúsculas
- Búsqueda de texto: Coincidencia de subcadena sin distinción entre mayúsculas y minúsculas (`localizedCaseInsensitiveContains`)
- Los filtros se combinan (lógica AND) cuando ambos están activos
- La ordenación se aplica después del Filtrado
- Alternar orden: Haz clic en el encabezado de la misma columna para invertir el orden
- El botón Borrar restablece los filtros, pero mantiene la preferencia de orden.

**Diálogo de edición (EditContactView):**

- Hoja modal para añadir/editar contactos
- Formulario con campos para Nombre, Teléfono 1 y Teléfono 2
- Los campos de teléfono filtran automáticamente las entradas no numéricas
- El campo ID es de sólo lectura (se genera automáticamente para los contactos nuevos)
- El botón Guardar se desactiva cuando el nombre está vacío
- Atajos de teclado (Escape para cancelar, Intro para guardar).

### 4. Sistema de traducción (LocalizationManager.swift)

**Detección automática de idioma:**

- Lee las preferencias de idioma del sistema macOS mediante `Locale.preferredLanguages`
- Admite tres idiomas: inglés (en), español (es) y francés (fr)
- Si el idioma del sistema no es compatible, utiliza el inglés como alternativa
- No requiere selección manual de idioma.

**Clase LocalizationManager:**

- Patrón `Singleton` (instancia única compartida)
- Detecta el idioma al inicializarse
- Proporciona el método `localizedString(_:)` para la búsqueda de claves
- Implementa la cadena de búsqueda: Idioma actual → Inglés → Clave.

**Función auxiliar global:**

- `localized(_:)` para un acceso sencillo en toda la aplicación
- Uso: `Text(localized("phone_numbers"))`.

## Compatibilidad de idiomas

### Idiomas compatibles

1. **Inglés (en)**: Idioma predeterminado y de respaldo
2. **Español (es)**: Traducción completa de los elementos de la interfaz de usuario
3. **Francés (fr)**: Traducción completa de los elementos de la interfaz de usuario.

### Proceso de detección

1. La aplicación lee las preferencias de idioma del sistema al iniciarse
2. Extrae el código de idioma (los dos primeros caracteres)
3. Comprueba si el código coincide con alguno de los idiomas compatibles
4. Selecciona la primera coincidencia o usa el inglés como idioma predeterminado
5. Carga el paquete `.lproj` correspondiente para la localización de cadenas.

### Agregar nuevos idiomas

Para agregar compatibilidad con idiomas adicionales:

1. Crea un nuevo directorio `.lproj` (por ejemplo, `de.lproj` para alemán)
2. Agrega el archivo `Localizable.strings` con las traducciones
3. Actualiza la matriz `supportedLanguages` en `LocalizationManager`
4. No se requieren cambios en el código de las vistas.

## Formato de datos

### Estructura XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Phonebook>
    <Contact>
        <Name>John Doe</Name>
        <Phone1>1234567890</Phone1>
        <Phone2>9876543210</Phone2>
        <ID>1</ID>
    </Contact>
    <!-- Más contactos... -->
</Phonebook>
```

**Requisitos:**

- Elemento raíz: `<Phonebook>`
- Cada contacto: elemento `<Contact>`
- Campos obligatorios: `<ID>` (entero), `<Name>`, `<Phone1>`, `<Phone2>`
- Números de teléfono: cadenas numéricas
- Los ID deben ser únicos.

El archivo XML se guarda en la carpeta de documentos del usuario (no en la app):

`~/Library/Containers/perez987.AgendaT/Data/Documents/Phonebook.xml`

## Consideraciones de diseño

### Rendimiento

- **LazyVGrid**: Representación eficiente para grandes conjuntos de datos (sólo se representan los elementos visibles)
- **Filtrado en memoria**: Todo el filtrado se realiza sobre el conjunto de datos cargado (sin volver a analizar)
- **Análisis XML único**: Los datos se cargan una sola vez al iniciar la aplicación
- **Ordenación alfabética**: Los contactos se ordenan mediante una comparación que tiene en cuenta la configuración regional
- **Ordenación eficiente**: La ordenación se aplica a los resultados filtrados, no al conjunto de datos completo.

### Experiencia de usuario

- **Ordenación por varias columnas**: Clic en cualquier encabezado de columna para ordenar; Clic de nuevo para invertir
- **Indicadores visuales de ordenación**: Los iconos de flecha muestran la columna de ordenación activa y la dirección
- **Orden alfabético**: Los contactos se pueden ordenar por nombre, número de teléfono o ID
- **Retroalimentación instantánea**: El botón de filtro proporciona control sobre la ejecución de la búsqueda
- **Indicadores visuales**: La letra seleccionada se resalta con color
- **Borrar**: Un solo botón restablece todos los filtros a su estado inicial
- **Cuadrícula adaptable**: Columna de nombre flexible, ancho fijo para teléfonos e ID
- **Funcionalidad de edición**: Clic en el nombre del contacto para editarlo, icono de papelera para eliminarlo
- **Edición modal**: Diálogo de edición con atajos de teclado
- **ID generados automáticamente**: Los nuevos contactos obtienen automáticamente ID únicos
- **Registro de depuración**: Salida de consola para una fácil identificación.

### Calidad del código

- **Separación de responsabilidades**: Modelos, vistas y lógica de análisis separados
- **Buenas prácticas de SwiftUI**: Interfaz de usuario basada en el estado, sintaxis declarativa
- **Manejo de errores**: Degradación controlada (array vacío en caso de fallo de carga XML)
- **Uso eficiente de la memoria**: Estructuras para tipos de valor, retención mínima de objetos.

## Oportunidades de mejora

### Funcionalidades potenciales

- Validación y formato de números de teléfono
- Optimización del modo oscuro
- Funcionalidad de importación/exportación para diferentes formatos
- Agrupación y categorización de contactos
- Historial de búsqueda.

### Localización

- Formato de fecha y número según la configuración regional
- Ordenación de contactos según la configuración regional.

## Requisitos de programación

### Requisitos del sistema

- macOS 13.0 (Ventura) o posterior
- Xcode 15.0 o posterior
- Swift 5.0 o posterior.

### Compilación del proyecto

1. Abre `AgendaT.xcodeproj` en Xcode
2. Selecciona dispositivo/arquitectura de destino
3. Compila y ejecuta (⌘R).

## Guía de estilo de código

### Convenciones de Swift

- CamelCase para propiedades y funciones (primera palabra empieza con minúscula, el resto con mayúscula, ej: `sortedEntries`)
- PascalCase para tipos (todas las palabras empiezan por mayúscula, ej: `LocalizationManager`)
- Nombres descriptivos en lugar de breves
- Comentarios para lógica no evidente
- Agrupar la funcionalidad relacionada con comentarios `// MARK:` (cuando corresponda).

### Patrones de SwiftUI

- Extraer las vistas complejas a componentes separados cuando sea necesario
- Usar `@State` para el estado local y `@StateObject` para objetos observables
- Preferir los modificadores al renderizado condicional
- Mantener las vistas concisas y legibles.

## Limitaciones conocidas

2. **Fuente de un único archivo**: Todos los datos deben caber en un solo archivo XML
3. **Sin validación de contactos**: No se impiden los ID duplicados ni los datos no válidos a nivel de la aplicación
4. **Sin sincronización con iCloud**: Sólo datos locales.

## Consideraciones de accesibilidad

- Todos los elementos interactivos son accesibles mediante teclado
- Compatible con VoiceOver (compatibilidad nativa con SwiftUI)
- El texto se adapta al tamaño de fuente del sistema
- Se mantiene la estructura semántica (encabezados, listas, botones).

## Seguridad y privacidad

- **Sin acceso a la red**: Aplicación totalmente offline
- **Sólo datos locales**: Archivo XML almacenado en el directorio de documentos del usuario
- **Sin seguimiento de usuarios**: Sin análisis ni telemetría
- **Sandbox**: Restricciones estándar del entorno aislado de macOS
- **Almacenamiento editable**: Los datos se guardan en la carpeta de documentos, accesible para el usuario
- **Texto XML**: Escapa los caracteres especiales XML (&, <, >, ', ").
