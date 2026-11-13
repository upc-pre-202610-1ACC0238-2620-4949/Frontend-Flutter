# SmartGas — App móvil (Flutter)

Versión Flutter de **SmartGas**, monitoreo de gas y temperatura en cocinas. Consume el mismo backend REST
que la web y la app Android (`SmartGas.Api`, ASP.NET Core + PostgreSQL).

## Arquitectura

Igual que la app Android, el código se organiza por **bounded contexts** y, dentro de cada uno, por capas.
Las llamadas REST siguen el estilo de los ejemplos del curso: `http` + `json.decode` + `setState`.

```
lib/
├── main.dart
├── common/                          ApiConfig (URL del backend), sesión, utilidades JSON
├── iam/                             Login
├── kitchenmonitoring/               Zonas, sensores y lecturas
├── incidentpreventionnotification/  Alertas (notificaciones + incidentes)
└── shared/                          Home, barra inferior, tema y widgets comunes
```

| Capa | Contenido |
|---|---|
| `data/` | Servicios HTTP (`XService`) que devuelven modelos de dominio |
| `domain/` | Modelos con `fromJson` |
| `presentation/` | Páginas (`StatefulWidget` + `setState`) |

## Pantallas (avance ~30 %)

| Diseño | Pantalla | Qué hace |
|---|---|---|
| 01–02 | Login | Inicia sesión y muestra el error de credenciales |
| 04 | Home | Estado general, métricas, zonas más urgentes y clima |
| 05 | Zonas | Lista con filtros Todas / Seguras / Advertencia / Críticas |
| 06 | Detalle de zona | Estado, últimas lecturas y sensores de la zona |
| 10 | Alertas | Filtros Activas / Confirmadas / Todas y botón Confirmar |

Pendiente: registro, detalle de sensor, agregar sensor, historial, ajustes, push y modo offline
(ya hechos en la versión Android).

## Cómo ejecutarlo

1. `flutter pub get`
2. `flutter run` con el emulador de Android abierto o un celular conectado.

La app apunta al backend desplegado en Render: `https://backend-rxmh.onrender.com/api/v1`
(`lib/common/api_config.dart`). El plan gratuito de Render apaga el servicio si no se usa, así que la primera
petición puede tardar unos 50 segundos.

Para usar la API local (`dotnet run` en SmartGas.Api o `node docs/mock/server.js` del repo Android, puerto
**5048**), cambiar `baseUrl` a `http://10.0.2.2:5048/api/v1`: **10.0.2.2** es la PC vista desde el emulador,
así que no hace falta `adb reverse`. En un celular real hay que poner la IP de la PC.

Usuario de prueba del mock: `usuario@smartgas.com` / `smartgas`.
