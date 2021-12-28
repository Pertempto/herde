import 'dart:math';

import 'animal.dart';
import 'data_store.dart';
import 'herd.dart';
import 'note.dart';

class AnimalManager {
  /* Add an animal to the herd. */
  static addAnimal(Herd herd, Animal animal) {
    if (animal.id.isEmpty) {
      animal = animal.copyWith(id: generateAnimalId(herd));
    }
    Map<String, Animal> newAnimals = Map.from(herd.animals);
    if (!newAnimals.containsKey(animal.id)) {
      newAnimals[animal.id] = animal;
      DataStore.updateHerd(herd: herd.copyWith(animals: newAnimals));
    }
  }

  /* Update an animal in the herd. */
  static updateAnimal(Herd herd, Animal animal) {
    if (animal.id.isEmpty) {
      animal = animal.copyWith(id: generateAnimalId(herd));
    }
    Map<String, Animal> newAnimals = Map.from(herd.animals);
    if (newAnimals.containsKey(animal.id)) {
      newAnimals[animal.id] = animal;
      DataStore.updateHerd(herd: herd.copyWith(animals: newAnimals));
    }
  }

  /* Remove an animal from the herd. */
  static removeAnimal(Herd herd, Animal animal) {
    Map<String, Animal> newAnimals = Map.from(herd.animals);
    newAnimals.remove(animal.id);
    DataStore.updateHerd(herd: herd.copyWith(animals: newAnimals));
  }

  /* Add a note to an animal. */
  static addNote(Herd herd, Animal animal, Note note) {
    if (note.id.isEmpty) {
      note = note.copyWith(id: generateNoteId(animal));
    }
    Map<String, Note> newNotes = Map.from(animal.notes);
    if (!newNotes.containsKey(note.id)) {
      newNotes[note.id] = note;
      updateAnimal(herd, animal.copyWith(notes: newNotes));
    }
  }

  /* Generate a new unique animal id for the herd. */
  static String generateAnimalId(Herd herd) {
    String id = generateId();
    while (herd.animals.keys.contains(id)) {
      id = generateId();
    }
    return id;
  }

  /* Generate a new unique note id for the animal. */
  static String generateNoteId(Animal animal) {
    String id = generateId();
    while (animal.notes.keys.contains(id)) {
      id = generateId();
    }
    return id;
  }

  /* Generate a random ID. */
  static String generateId() {
    String id = '';
    String options = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    Random rand = Random();
    for (int i = 0; i < 8; i++) {
      id += options[rand.nextInt(options.length)];
    }
    return id;
  }
}
