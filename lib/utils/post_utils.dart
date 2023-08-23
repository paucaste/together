import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

Widget postMenuButton(Function onDelete, Function onEdit) {
  return PopupMenuButton<String>(
    onSelected: (value) {
      switch (value) {
        case 'editar':
          onEdit();
          break;
        case 'borrar':
          onDelete();
          break;
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'editar',
        child: Text('Editar'),
      ),
      PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'borrar',
        child: Text('Borrar'),
      ),
    ],
    icon: Icon(Icons.more_vert), // Ícono de 3 puntos
  );
}
