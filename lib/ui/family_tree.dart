import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphview/GraphView.dart';

import '../data/animal.dart';
import '../data/data_store.dart';
import 'category_icon.dart';

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
      ..levelSeparation = (80)
      ..orientation = SugiyamaConfiguration.ORIENTATION_LEFT_RIGHT;
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
            Node unknownNode = Node.Id(null);
            Map<String, Node> nodes = {};
            Map<String, Node> parentNodes = {};
            for (Animal animal in herd!.animals.values) {
              nodes[animal.id] = Node.Id(animal);
              parentNodes[(animal.fatherId ?? '') + '+' + (animal.motherId ?? '')];
            }
            List<Animal> animalListByAge = herd.animals.values.toList();
            // Sort the animals by oldest to youngest.
            animalListByAge.sort((Animal a, Animal b) {
              if (a.birthDate == null) return 1;
              if (b.birthDate == null) return -1;
              return a.birthDate!.compareTo(b.birthDate!);
            });
            List<Animal> animalList = [];
            addAnimal(Animal animal) {
              animalListByAge.remove(animal);
              if (!animalList.contains(animal)) {
                animalList.add(animal);
                for (Animal child in herd.getChildren(animal)) {
                  addAnimal(child);
                }
              }
            }

            while (animalListByAge.isNotEmpty) {
              addAnimal(animalListByAge.first);
            }
            for (Animal animal in animalList) {
              if (animal.fatherId != null) {
                graph.addEdge(
                  nodes[animal.id]!,
                  nodes[animal.fatherId]!,
                  paint: Paint()
                    ..color = Colors.blue
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              } else {
                graph.addEdge(
                  nodes[animal.id]!,
                  unknownNode,
                  paint: Paint()
                    ..color = Colors.transparent
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
              } else {
                graph.addEdge(
                  nodes[animal.id]!,
                  unknownNode,
                  paint: Paint()
                    ..color = Colors.transparent
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
                    return nodeWidget(node.key!.value);
                  },
                )),
          );
        });
  }

  Widget nodeWidget(Animal? a) {
    if (a == null) {
      return Container();
    }
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(typeName: a.typeName, categoryName: a.categoryName),
                const SizedBox(width: 8),
                Text(a.fullName),
              ],
            ),
            if (a.birthDate != null) Text('Age: ${a.ageString}')
          ],
        ),
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
