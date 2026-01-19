# Booktion 📚

Aplicación Flutter para gestionar tu biblioteca personal conectada a una base de datos de Notion.

## Características

- 📖 **Ver tu colección de libros** desde Notion
- 🔍 **Buscar y filtrar** por estado (Pendiente, En curso, Terminado)
- ⭐ **Valoraciones** con estrellas
- ✏️ **CRUD completo**: Crear, editar y eliminar libros
- 🌙 **Tema oscuro** elegante inspirado en lectores de ebooks
- 🏗️ **Clean Architecture** con separación de capas

## Arquitectura

El proyecto sigue **Clean Architecture** con estructura Feature-First:

```
lib/
├── core/                    # Código compartido
│   ├── config/              # Configuración (env vars)
│   ├── error/               # Manejo de errores (Failures, Exceptions)
│   ├── network/             # Cliente HTTP (Dio)
│   ├── router/              # Navegación (GoRouter)
│   └── theme/               # Tema de la app
│
└── features/
    └── books/
        ├── domain/          # Entidades, repositorios abstractos, casos de uso
        ├── data/            # Modelos, datasources, implementación de repos
        └── presentation/    # Páginas, widgets, providers (Riverpod)
```

## Configuración

### 1. Crear integración en Notion

1. Ve a [https://www.notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Crea una nueva integración
3. Copia el **Internal Integration Token** (empieza con `secret_`)

### 2. Compartir la base de datos con la integración

1. Abre tu base de datos de libros en Notion
2. Haz clic en **...** (menú) → **Conexiones** → Selecciona tu integración
3. Copia el **Database ID** de la URL:
   ```
   https://www.notion.so/TU_DATABASE_ID?v=...
   ```

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
NOTION_API_KEY=secret_tu_api_key_aqui
NOTION_DATABASE_ID=tu_database_id_aqui
```

### 4. Estructura esperada de la base de datos

La app espera una base de datos con las siguientes propiedades:

| Propiedad | Tipo | Requerido |
|-----------|------|-----------|
| Nombre | Title | ✅ |
| Autor | Rich text | ✅ |
| Serie | Rich text | ❌ |
| Estado | Select (Pendiente, En curso, Terminado) | ❌ |
| Valoración | Select (⭐️ a ⭐️⭐️⭐️⭐️⭐️) | ❌ |
| Etiquetas | Multi-select | ❌ |
| Género | Multi-select | ❌ |
| Nº Páginas | Number | ❌ |
| Posición | Number | ❌ |
| Resumen | Rich text | ❌ |
| Terminado | Date | ❌ |
| URL | URL | ❌ |

## Instalación y Ejecución

```bash
# Instalar dependencias
flutter pub get

# Generar código (freezed, riverpod_generator, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar la app
flutter run
```

## Tecnologías

- **Flutter** 3.5+
- **Riverpod** - State management + DI
- **Dio** - HTTP Client
- **Freezed** - Inmutabilidad y union types
- **fpdart** - Programación funcional (Either)
- **GoRouter** - Navegación declarativa
- **Google Fonts** - Tipografía (Playfair Display, Inter)

## Licencia

MIT License
