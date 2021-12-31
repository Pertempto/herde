import '../data/animal.dart';
import '../data/herd.dart';

enum Field {
  none,
  tagNumber,
  name,
  category,
  age,
  father,
  mother,
}

class SortFilter {
  static final Map<Field, Function> _sortFunctions = {
    Field.tagNumber: (_, sortFactor) => (Animal a, Animal b) {
          if (a.tagNumber == -1) return 1;
          if (b.tagNumber == -1) return -1;
          return a.tagNumber.compareTo(b.tagNumber) * sortFactor;
        },
    Field.name: (_, sortFactor) => (Animal a, Animal b) {
          if (a.name.isEmpty) return 1;
          if (b.name.isEmpty) return -1;
          return a.name.compareTo(b.name) * sortFactor;
        },
    Field.age: (_, sortFactor) => (Animal a, Animal b) {
          if (a.birthDate == null) return 1;
          if (b.birthDate == null) return -1;
          return -a.birthDate!.compareTo(b.birthDate!) * sortFactor;
        },
    Field.category: (_, sortFactor) => (Animal a, Animal b) {
          return a.category.sortIndex.compareTo(b.category.sortIndex) * sortFactor;
        },
    Field.father: (herd, sortFactor) => (Animal a, Animal b) {
          if (herd.animals[a.fatherId] == null) return 1;
          if (herd.animals[b.fatherId] == null) return -1;
          Animal aFather = herd.animals[a.fatherId]!;
          Animal bFather = herd.animals[b.fatherId]!;
          return aFather.fullName.compareTo(bFather.fullName) * sortFactor;
        },
    Field.mother: (herd, sortFactor) => (Animal a, Animal b) {
          if (herd.animals[a.motherId] == null) return 1;
          if (herd.animals[b.motherId] == null) return -1;
          Animal aMother = herd.animals[a.motherId]!;
          Animal bMother = herd.animals[b.motherId]!;
          return aMother.fullName.compareTo(bMother.fullName) * sortFactor;
        },
  };

  static final Map<Field, Function(String?)> _filterFunctions = {
    Field.none: (_) => (Animal a) => true,
    Field.father: (fatherId) => (Animal a) => a.fatherId == fatherId,
    Field.mother: (motherId) => (Animal a) => a.motherId == motherId,
  };

  Field sortField = Field.age;
  bool ascendingSort = true;
  Field filterField = Field.none;
  String? filterValue;

  String get sortFieldName => fieldName(sortField);

  int get sortFactor => ascendingSort ? 1 : -1;

  Iterable<Field> get sortFields => Field.values.where((field) => _sortFunctions.containsKey(field));

  Iterable<Field> get filterFields => Field.values.where((field) => _filterFunctions.containsKey(field));

  static String fieldName(Field field) {
    switch (field) {
      case Field.none:
        return 'None';
      case Field.tagNumber:
        return 'Tag Number';
      case Field.name:
        return 'Name';
      case Field.age:
        return 'Age';
      case Field.category:
        return 'Category';
      case Field.father:
        return 'Father';
      case Field.mother:
        return 'Mother';
    }
  }

  List<Animal> process(Herd herd) {
    List<Animal> output = herd.animals.values.toList();
    if (_filterFunctions.containsKey(filterField)) {
      output = output.where(_filterFunctions[filterField]!(filterValue)).toList();
    }
    if (_sortFunctions.containsKey(sortField)) {
      output.sort((a, b) => _sortFunctions[sortField]!(herd, sortFactor)(a, b));
    }
    return output;
  }

  String getFilterString(Herd herd) {
    if (filterField == Field.none) {
      return 'Filter';
    } else if (filterField == Field.father) {
      Animal? father = herd.animals[filterValue];
      if (father == null) {
        return '"Father is unknown"';
      } else {
        return '"Father is ${father.fullName}"';
      }
    } else if (filterField == Field.mother) {
      Animal? mother = herd.animals[filterValue];
      if (mother == null) {
        return '"Mother is unknown"';
      } else {
        return '"Mother is ${mother.fullName}"';
      }
    }
    return '??';
  }
}
