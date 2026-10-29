# App web de HandSense

Esta es una primera interfaz funcional. Abre la página en un navegador para explorar **datos simulados**; todavía no hay mediciones físicas ni conexión ESP32 verificada. La app no usa cuentas, paquetes de JavaScript ni servicios externos para funcionar. El sistema usa fuentes locales si no hay internet.

## Abrir la demostración

Desde esta carpeta:

```bash
python3 -m http.server 8000
```

Abrir `http://localhost:8000` en el navegador. El servidor local es necesario porque la página usa módulos JavaScript. Para detenerlo, presionar `Ctrl+C`.

Para ejecutar las pruebas de contrato y escenarios: `node --test data.test.js`.

Pruebas disponibles: pinza completa, solo flexión, solo contacto, contacto sostenido y señal no confiable. Los porcentajes y los tiempos son **ilustrativos**: no representan la respuesta de los sensores físicos ni validan el algoritmo final. Las preferencias de texto, contraste, movimiento y anuncios se guardan en el navegador.

## Conectar al ESP32 más adelante

La app puede servirse desde el propio ESP32. En modo `ESP32`, consulta `GET /api/estado` cada segundo y envía acciones a `POST /api/acciones`. El contrato exacto está en [PROTOCOLO.md](PROTOCOLO.md). La app debe abrirse desde la dirección del ESP32 para que las rutas sean del mismo origen y funcionen sin CORS. El ESP32 continuará ejecutando la lógica de conteo y los avisos físicos si el navegador se desconecta.

Esta versión no es una PWA instalable: una página servida por HTTP desde una IP local no cumple normalmente el requisito de contexto seguro para un *service worker*. Se podrá evaluar una versión instalable si aporta algo al proyecto.
