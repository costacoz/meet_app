// import 'package:flutter/material.dart';
// import 'package:gtk_flutter/src/widgets.dart';
//
// import '../main.dart';
//
// class YesNoSelection extends StatelessWidget {
//   const YesNoSelection({required this.state, required this.onSelection});
//   final Attending state;
//   final void Function(Attending selection) onSelection;
//
//   @override
//   Widget build(BuildContext context) {
//     switch (state) {
//       case Attending.yes:
//         return Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(elevation: 0),
//                 onPressed: () => onSelection(Attending.yes),
//                 child: Text('YES'),
//               ),
//               SizedBox(width: 8),
//               TextButton(
//                 onPressed: () => onSelection(Attending.no),
//                 child: Text('NO'),
//               ),
//             ],
//           ),
//         );
//       case Attending.no:
//         return Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               TextButton(
//                 onPressed: () => onSelection(Attending.yes),
//                 child: Text('YES'),
//               ),
//               SizedBox(width: 8),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(elevation: 0),
//                 onPressed: () => onSelection(Attending.no),
//                 child: Text('NO'),
//               ),
//             ],
//           ),
//         );
//       default:
//         return Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               StyledButton(
//                 onPressed: () => onSelection(Attending.yes),
//                 child: Text('YES'),
//               ),
//               SizedBox(width: 8),
//               StyledButton(
//                 onPressed: () => onSelection(Attending.no),
//                 child: Text('NO'),
//               ),
//             ],
//           ),
//         );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:gtk_flutter/helpers/attending.dart';
import 'package:gtk_flutter/src/widgets.dart';

import '../main.dart';

class YesNoSelection extends StatelessWidget {
  const YesNoSelection({required this.state, required this.onSelection});
  final Attending state;
  final void Function(Attending selection) onSelection;

  void setNotAttending() {
    onSelection(Attending.no);
  }
  void setAttending() {
    onSelection(Attending.yes);
  }

  @override
  Widget build(BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              state == Attending.yes ? ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: setAttending,
                child: const Text('YES'),
              ) : state == Attending.no ?
              TextButton(
                onPressed: setAttending,
                child: const Text('YES'),
              ) : StyledButton(
                onPressed: setAttending,
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              state == Attending.yes ? TextButton(
                onPressed: setNotAttending,
                child: const Text('NO'),
              ) : state == Attending.no ? ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: setNotAttending,
                child: const Text('NO'),
              ) : StyledButton(
                onPressed: setNotAttending,
                child: const Text('NO'),
              ),
            ],
          ),
        );
  }
}