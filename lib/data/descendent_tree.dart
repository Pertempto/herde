import 'animal.dart';

class DescendentTree {
  Animal root;
  List<DescendentTree> branches;

  // Pre-order traversal
  List<Animal> get allMembers {
    List<Animal> members = [root];
    for (DescendentTree branch in branches) {
      members.addAll(branch.allMembers);
    }
    return members;
  }

  DescendentTree({required this.root, required this.branches});
}
