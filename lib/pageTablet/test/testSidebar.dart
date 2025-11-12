// import 'dart:developer';

// import 'package:flutter/material.dart';

// class NavigationRailExample extends StatefulWidget {
//   const NavigationRailExample({super.key});

//   NavigationRailExampleState createState() => NavigationRailExampleState();
// }

// class NavigationRailExampleState extends State<NavigationRailExample> {
//   int? _selectedIndex;
//   double? wdthSide;
//   bool switchOn = true;

//   @override
//   initState() {
//     super.initState();

//     _selectedIndex = 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: <Widget>[
//           Container(
//             color: Colors.blue,
//             width: wdthSide,
//             child: Column(
//               children: const [
//                 Icon(Icons.add),
//                 Icon(Icons.add),
//                 Icon(Icons.add),
//                 Icon(Icons.add),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 Text('Content of Menu $_selectedIndex'),
//                 Transform.scale(
//                   scale: 2.0,
//                   child: Switch(
//                     onChanged: (value) {
//                       setState(() {
//                         switchOn = value;
//                         log(switchOn.toString());
//                         setState(() {
//                           value == true ? wdthSide = 228 : wdthSide = 84;
//                         });
//                       });
//                     },
//                     value: switchOn,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<NavigationRailDestination> _buildDestinations() {
//     return const [
//       NavigationRailDestination(
//         icon: Icon(Icons.one_k),
//         label: Text('Menu 1'),
//       ),
//       NavigationRailDestination(
//         icon: Icon(Icons.two_k),
//         label: Text('Menu 2'),
//       ),
//       NavigationRailDestination(
//         icon: Icon(Icons.three_k),
//         label: Text('Menu 3'),
//       ),
//     ];
//   }
// }
