import 'package:flutter/material.dart';
import 'app_theme.dart';

class Calendario extends StatelessWidget {
  const Calendario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.handshake), // Puedes cambiar por tu logo
        ),
        title: const Text("Titulo"),
      ),
      body: const Center(
        child: Text(
          "Hola, este es un texto con el estilo definido en el tema.",
          style: AppTheme.bodyStyle,
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explorar"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Billetera",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Estadísticas",
          ),
        ],
      ),
    );
  }
}


//   @override
//   Widget build(BuildContext context) {
 
//     return Scaffold(
//       appBar: AppBar(

//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(

//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
