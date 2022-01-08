import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphview/GraphView.dart';

import '../data/animal.dart';
import '../data/category.dart';
import '../data/data_store.dart';
import '../data/descendent_tree.dart';
import '../data/herd.dart';
import 'category_icon.dart';

class FamilyTree extends StatefulWidget {
  final String herdId;

  const FamilyTree({required this.herdId, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FamilyTreeState();
}

class _FamilyTreeState extends State<FamilyTree> {
  // final Graph graph = Graph();
  // SugiyamaConfiguration builder = SugiyamaConfiguration();
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  Parent treeType = Parent.mother;
  bool isVertical = false;
  bool showMates = false;

  @override
  void initState() {
    super.initState();

    builder
      ..siblingSeparation = 0
      ..levelSeparation = 16
      ..subtreeSeparation = 0
      ..orientation = (isVertical
          ? BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
          : BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
  }

  @override
  Widget build(BuildContext context) {
    return DataStore.herdWidget(
        herdId: widget.herdId,
        builder: (herd, bool isLoading) {
          if (herd == null) {
            Navigator.of(context).pop();
          }
          Node unknownNode = Node.Id('ROOT');
          Paint partnerPaint = Paint()
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.red;
          Paint childPaint = Paint()
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.green;
          Paint invisiblePaint = Paint()..color = Colors.transparent;
          Map<String, Node> nodes = {};
          for (Animal animal in herd!.animals.values) {
            nodes[animal.id] = Node.Id(animal.id);
          }
          List<Animal> animalListByAge = herd.animals.values.toList();
          // Sort the animals by oldest to youngest.
          animalListByAge.sort((Animal a, Animal b) {
            if (a.birthDate == null) return 1;
            if (b.birthDate == null) return -1;
            return a.birthDate!.compareTo(b.birthDate!);
          });
          // Sort the animals by the number of children.
          animalListByAge.sort((Animal a, Animal b) {
            return -herd
                .getChildren(animal: a, parent: treeType)
                .length
                .compareTo(herd.getChildren(animal: b, parent: treeType).length);
          });

          List<Animal> animalList = [];
          addAnimal(Animal animal) {
            if (animalListByAge.remove(animal)) {
              DescendentTree tree = herd.getDescendentTree(animal, parent: treeType);
              List<Animal> members = tree.allMembers;
              if (members.length > 1) {
                for (Animal descendant in members) {
                  if (!animalList.contains(descendant)) {
                    animalList.add(descendant);
                    animalListByAge.remove(descendant);
                  }
                }
              }
            }
          }

          while (animalListByAge.isNotEmpty) {
            addAnimal(animalListByAge.first);
          }
          graph.nodes.clear();
          graph.edges.clear();
          for (Animal animal in animalList) {
            if (treeType == Parent.father) {
              if (animal.fatherId != null) {
                if (showMates) {
                  Node breedNode;
                  if (animal.motherId != null) {
                    breedNode = Node.Id(animal.fatherId! + '.' + animal.motherId!);
                  } else {
                    breedNode = Node.Id(animal.fatherId! + '.' + 'UNKNOWN-MOTHER');
                  }
                  graph.addEdge(nodes[animal.fatherId]!, breedNode, paint: partnerPaint);
                  graph.addEdge(breedNode, nodes[animal.id]!, paint: childPaint);
                } else {
                  graph.addEdge(nodes[animal.fatherId]!, nodes[animal.id]!, paint: childPaint);
                }
              } else {
                graph.addEdge(unknownNode, nodes[animal.id]!, paint: invisiblePaint);
              }
            } else {
              if (animal.motherId != null) {
                if (showMates) {
                  Node breedNode;
                  if (animal.fatherId != null) {
                    breedNode = Node.Id(animal.motherId! + '.' + animal.fatherId!);
                  } else {
                    breedNode = Node.Id(animal.motherId! + '.' + 'UNKNOWN-FATHER');
                  }
                  graph.addEdge(nodes[animal.motherId]!, breedNode, paint: partnerPaint);
                  graph.addEdge(breedNode, nodes[animal.id]!, paint: childPaint);
                } else {
                  graph.addEdge(nodes[animal.motherId]!, nodes[animal.id]!, paint: childPaint);
                }
              } else {
                graph.addEdge(unknownNode, nodes[animal.id]!, paint: invisiblePaint);
              }
            }
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Family Tree')),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.up,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  elevation: 2,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    height: 136,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Tree Type'),
                            const SizedBox(width: 16),
                            CupertinoSlidingSegmentedControl<Parent>(
                              children: const {
                                Parent.mother: Text('Matriarchal'),
                                Parent.father: Text('Patriarchal'),
                              },
                              groupValue: treeType,
                              onValueChanged: (value) => setState(() => treeType = value!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Tree View'),
                            const SizedBox(width: 16),
                            CupertinoSlidingSegmentedControl<bool>(
                              children: const {
                                true: Text('Vertical'),
                                false: Text('Horizontal'),
                              },
                              groupValue: isVertical,
                              onValueChanged: (value) => setState(() {
                                isVertical = value!;
                                builder.orientation = (isVertical
                                    ? BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
                                    : BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT);
                              }),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Show Mates'),
                            const SizedBox(width: 16),
                            Checkbox(value: showMates, onChanged: (value) => setState(() => showMates = value == true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (graph.nodes.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Tree is empty.')),
                if (graph.nodes.isNotEmpty)
                  Expanded(
                    child: InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.1,
                      maxScale: 2,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                        builder: (Node node) {
                          return nodeWidget(herd, node.key!.value);
                        },
                      ),
                    ),
                  ),
              ].reversed.toList(),
            ),
          );
        });
  }

  Widget nodeWidget(Herd herd, String id) {
    if (id.contains('.')) {
      id = id.split('.')[1];
    }
    if (id == 'UNKNOWN-FATHER') {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Text('Unknown\nFather', textAlign: TextAlign.center),
        ),
      );
    } else if (id == 'UNKNOWN-MOTHER') {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const Text('Unknown\nMother', textAlign: TextAlign.center),
        ),
      );
    }
    Animal? a = herd.animals[id];
    if (a == null) {
      return Container();
    }
    return Card(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
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
