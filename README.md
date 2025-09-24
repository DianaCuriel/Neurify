1. Main: Esta es la pagina principal, en donde se corre nuestro programa
1.1. Se importan librerias 
1.2. Se manda a llamar la clase Myapp
    1.2.1. En la clase MyApp se le asigna titulo, se manda a llamar al tema por defecto de Fijo/app_theme.dart y se coloca un home en el login para que sea la primera pantalla. 


2. Fijo: La finalidad de esta carpeta es guardar todas las pages que contenga cosas que se usan en toda la app para reutilizar codigo. 
2.a. app_theme.dart
    2.a.1. Se importan librerías 
    2.a.2. Empieza la clase de AppTheme
        2.a.2.1. Es para la asignación de colores. 
        2.a.2.2. Se asigna diferentes estilos que se utilizaran en el codigo.
        2.a.2.3. Configuración de tipografías: 
          Se definen los estilos de texto globales (TextTheme) que se aplican
          en toda la app: tamaño, peso, fuente, colores del texto.  
        2.a.2.4. Configuración de componentes (ThemeData): 
          Se definen estilos globales para botones, AppBar, iconos,
          campos de texto, etc. Esto permite mantener un estilo uniforme
          en toda la aplicación sin repetir código en cada widget.


3. Modelos: La finalidad de esta carpeta es poner todos los modelos que se van a utilizar dentro de la app, tal que el modelo sirve para representar y manejar la información (datos) de manera organizada.
3.a. Calendar_model.dart
    3.a.1. se define una class 
        3.a.1.2 se inicializan las variables con un final, porque queremos que se mantengan inmutables
        3.a.1.3 se hace el constructor y se le asigna el valor como requiered para que sean necesario porque son datos  
                que si o si ocupa el metodo.

4. Visuales: Estas pages contienen la parte visual y funcional de la aplicacion 

4.b.1. Imports
    4.b.1.1. flutter/material.dart → librerías principales de Flutter.
    4.b.1.2. intl.dart → para formatear fechas y horas.
    4.b.1.3. table_calendar.dart → paquete de terceros para mostrar calendarios en Flutter.
    4.b.1.4. app_theme.dart → archivo interno con estilos de la app.
    4.b.1.5. calendario_model.dart → modelo que define la clase Cliente (citas).

4.b.2. typedef
    4.b.2.1. Se define OnDateSelected como un tipo de función que recibe un DateTime.
    4.b.2.2. Esto permite pasar funciones como callback cuando se selecciona una fecha.

4.b.3. class CalendarCard (StatefulWidget)

4.b.3.1. Se crea la clase CalendarCard que representa el widget del calendario.
4.b.3.2. Esta clase es Stateful porque necesita manejar estados (día seleccionado, citas cargadas, etc.).

4.b.4. Propiedades de CalendarCard

4.b.4.1. initialDate → fecha inicial a mostrar.
4.b.4.2. onDateSelected → callback que se dispara cuando se selecciona una fecha.
4.b.4.3. primaryColor → color principal del calendario (por defecto el de AppTheme).
4.b.4.4. citas → lista de objetos Cliente que representan citas en el calendario.
4.b.4.5. isMonthlyView → bool que indica si la vista actual es mensual o semanal.
4.b.4.6. onToggleView → callback que alterna entre vista mensual y semanal.

4.b.5. class _CalendarCardState (estado interno)

4.b.5.1. _baseMonday → calcula el lunes base de la semana mostrada.
4.b.5.2. citasMap → mapa que guarda citas indexadas por fecha/hora (clave: "dd-MM-yyyy HH:mm").
4.b.5.3. _hours → lista de 0 a 23 para representar todas las horas del día.
4.b.5.4. _pageController → controla el PageView del calendario semanal.
4.b.5.5. _focusedDay y _selectedDay → manejan el día actual/seleccionado en el calendario mensual.

4.b.6. initState()

4.b.6.1. Se obtiene la fecha actual (o la inicial pasada como parámetro).
4.b.6.2. Se calcula el lunes correspondiente.
4.b.6.3. Se cargan las citas iniciales con _loadCitas().

4.b.7. _loadCitas()

4.b.7.1. Limpia el mapa citasMap.
4.b.7.2. Convierte la fecha y hora de cada cita (Cliente) en un objeto DateTime.
4.b.7.3. Usa ese DateTime como clave en formato "dd-MM-yyyy HH:mm".
4.b.7.4. Maneja posibles errores al parsear las fechas.

4.b.8. didUpdateWidget()

4.b.8.1. Verifica si las citas cambiaron respecto al widget anterior.
4.b.8.2. Si cambiaron, vuelve a cargarlas y refresca la vista con setState().

4.b.9. Métodos auxiliares

4.b.9.1. _getMondayForPage() → calcula qué lunes corresponde a la página actual del PageView.
4.b.9.2. _getWeekDays() → genera la lista de 7 días a partir de un lunes.
4.b.9.3. _formatHour() → convierte una hora en formato 24h a 12h con AM/PM.

4.b.10. build() → interfaz gráfica

4.b.10.1. Se obtiene el lunes y los días de la semana según la página actual.
4.b.10.2. Se construye un Card con padding, borde redondeado y color de fondo.
4.b.10.3. Dentro del Card se muestra:

Subtítulo toggle → un texto que permite alternar entre “Vista mensual” o “Vista semanal”.

Encabezado → si es semanal, muestra el mes y el rango de fechas de la semana.

Contenido principal:

Si isMonthlyView es true → se muestra un TableCalendar con personalización:

Día actual resaltado.

Día seleccionado con estilo diferente.

Encabezado del mes centrado.

Si isMonthlyView es false → se usa un PageView con un Table que simula el calendario semanal:

Columnas = días de la semana.

Filas = horas del día.

Si hay cita (cita != null) → se pinta un recuadro con el nombre del cliente.

Si no hay cita → se deja el espacio vacío.

