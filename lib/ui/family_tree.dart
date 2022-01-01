import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphview/GraphView.dart';

import '../data/animal.dart';
import '../data/data_store.dart';

class FamilyTree extends StatefulWidget {
  final String herdId;

  const FamilyTree({required this.herdId, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FamilyTreeState();
}

class _FamilyTreeState extends State<FamilyTree> {
  final Graph graph = Graph();
  SugiyamaConfiguration builder = SugiyamaConfiguration();

  @override
  void initState() {
    super.initState();

    builder
      ..iterations = (50)
      ..nodeSeparation = (50)
      ..levelSeparation = (50)
      ..orientation = SugiyamaConfiguration.ORIENTATION_BOTTOM_TOP;
  }

  @override
  Widget build(BuildContext context) {
    return DataStore.herdWidget(
        herdId: widget.herdId,
        builder: (herd) {
          if (herd == null) {
            Navigator.of(context).pop();
          }
          if (graph.nodes.isEmpty) {
            Map<String, Node> nodes = {};
            for (Animal animal in herd!.animals.values) {
              nodes[animal.id] = Node.Id(animal.fullName);
            }
            for (Animal animal in herd.animals.values) {
              // graph.addNode(nodes[animal.id]!);
              if (animal.fatherId != null) {
                graph.addEdge(
                  nodes[animal.id]!,
                  nodes[animal.fatherId]!,
                  paint: Paint()
                    ..color = Colors.blue
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              }
              if (animal.motherId != null) {
                graph.addEdge(
                  nodes[animal.id]!,
                  nodes[animal.motherId]!,
                  paint: Paint()
                    ..color = Colors.pink
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              }
            }
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Family Tree')),
            body: InteractiveViewer(
                constrained: false,
                boundaryMargin: EdgeInsets.all(1000),
                minScale: 0.00001,
                maxScale: 100,
                child: GraphView(
                  graph: graph,
                  algorithm: SugiyamaAlgorithm(builder),
                  builder: (Node node) {
                    return rectangleWidget(node.key!.value);
                  },
                )),
          );
        });
  }

  Widget rectangleWidget(String? a) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Text(a ?? 'BLANK'),
      ),
    );
  }
}

// class _FamilyTreeState extends State<FamilyTree> {
//   final TransformationController _transformationController = TransformationController();
//   final Graph graph = Graph()..isTree = true;
//   BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
//
//   @override
//   void initState() {
//     super.initState();
//     builder
//       ..siblingSeparation = (10)
//       ..levelSeparation = (15)
//       ..subtreeSeparation = (15)
//       ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DataStore.herdWidget(
//         herdId: widget.herdId,
//         builder: (herd) {
//           if (herd == null) {
//             Navigator.of(context).pop();
//           }
//           if (graph.nodes.isEmpty) {
//             Map<String, Node> nodes = {};
//             for (Animal animal in herd!.animals.values) {
//               nodes[animal.id] = Node.Id(animal.fullName);
//             }
//             for (Animal animal in herd.animals.values) {
//               // graph.addNode(nodes[animal.id]!);
//               if (animal.fatherId != null) {
//                 graph.addEdge(nodes[animal.fatherId]!, nodes[animal.id]!);
//               }
//               if (animal.motherId != null) {
//                 graph.addEdge(nodes[animal.motherId]!, nodes[animal.id]!);
//               }
//             }
//           }
//           return Scaffold(
//             appBar: AppBar(title: const Text('Family Tree')),
//             body: Center(
//               child: InteractiveViewer(
//                 constrained: false,
//                 boundaryMargin: const EdgeInsets.all(double.infinity),
//                 transformationController: _transformationController,
//                 minScale: 0.01,
//                 maxScale: 100,
//                 child: GraphView(
//                   graph: graph,
//                   algorithm: builder,
//                   builder: (Node node) {
//                     return Text(node.key?.value.toString() ?? 'BLANK');
//                   },
//                   paint: Paint()
//                     ..color = Colors.black
//                     ..strokeWidth = 1
//                     ..style = PaintingStyle.stroke,
//                 ),
//               ),
//             ),
//           );
//         });
//   }
// }
