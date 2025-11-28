import 'dart:math';

class Question {
  final String portuguese;
  final Map<String, String> translations;
  Question({required this.portuguese, required this.translations});
}

/// Retorna a lista completa de perguntas seed (fallback).
List<Question> getSeedQuestions() {
  return [
    Question(portuguese: 'Casa', translations: {
      'Inglês': 'House',
      'Espanhol': 'Casa',
      'Francês': 'Maison'
    }),
    Question(portuguese: 'Cachorro', translations: {
      'Inglês': 'Dog',
      'Espanhol': 'Perro',
      'Francês': 'Chien'
    }),
    Question(
        portuguese: 'Gato',
        translations: {'Inglês': 'Cat', 'Espanhol': 'Gato', 'Francês': 'Chat'}),
    Question(portuguese: 'Carro', translations: {
      'Inglês': 'Car',
      'Espanhol': 'Coche',
      'Francês': 'Voiture'
    }),
    Question(portuguese: 'Livro', translations: {
      'Inglês': 'Book',
      'Espanhol': 'Libro',
      'Francês': 'Livre'
    }),
    Question(portuguese: 'Sol', translations: {
      'Inglês': 'Sun',
      'Espanhol': 'Sol',
      'Francês': 'Soleil'
    }),
    Question(portuguese: 'Lua', translations: {
      'Inglês': 'Moon',
      'Espanhol': 'Luna',
      'Francês': 'Lune'
    }),
    Question(portuguese: 'Água', translations: {
      'Inglês': 'Water',
      'Espanhol': 'Agua',
      'Francês': 'Eau'
    }),
    Question(portuguese: 'Comida', translations: {
      'Inglês': 'Food',
      'Espanhol': 'Comida',
      'Francês': 'Nourriture'
    }),
    Question(portuguese: 'Amigo', translations: {
      'Inglês': 'Friend',
      'Espanhol': 'Amigo',
      'Francês': 'Ami'
    }),
    Question(portuguese: 'Escola', translations: {
      'Inglês': 'School',
      'Espanhol': 'Escuela',
      'Francês': 'École'
    }),
    Question(portuguese: 'Cidade', translations: {
      'Inglês': 'City',
      'Espanhol': 'Ciudad',
      'Francês': 'Ville'
    }),
    Question(portuguese: 'Rua', translations: {
      'Inglês': 'Street',
      'Espanhol': 'Calle',
      'Francês': 'Rue'
    }),
    Question(portuguese: 'Família', translations: {
      'Inglês': 'Family',
      'Espanhol': 'Familia',
      'Francês': 'Famille'
    }),
    Question(portuguese: 'Trabalho', translations: {
      'Inglês': 'Work',
      'Espanhol': 'Trabajo',
      'Francês': 'Travail'
    }),
    Question(portuguese: 'Tempo', translations: {
      'Inglês': 'Time',
      'Espanhol': 'Tiempo',
      'Francês': 'Temps'
    }),
    Question(
        portuguese: 'Dia',
        translations: {'Inglês': 'Day', 'Espanhol': 'Día', 'Francês': 'Jour'}),
    Question(portuguese: 'Noite', translations: {
      'Inglês': 'Night',
      'Espanhol': 'Noche',
      'Francês': 'Nuit'
    }),
    Question(portuguese: 'Menino', translations: {
      'Inglês': 'Boy',
      'Espanhol': 'Niño',
      'Francês': 'Garçon'
    }),
    Question(portuguese: 'Menina', translations: {
      'Inglês': 'Girl',
      'Espanhol': 'Niña',
      'Francês': 'Fille'
    }),
    Question(portuguese: 'Mãe', translations: {
      'Inglês': 'Mother',
      'Espanhol': 'Madre',
      'Francês': 'Mère'
    }),
    Question(portuguese: 'Pai', translations: {
      'Inglês': 'Father',
      'Espanhol': 'Padre',
      'Francês': 'Père'
    }),
    Question(portuguese: 'Irmão', translations: {
      'Inglês': 'Brother',
      'Espanhol': 'Hermano',
      'Francês': 'Frère'
    }),
    Question(portuguese: 'Irmã', translations: {
      'Inglês': 'Sister',
      'Espanhol': 'Hermana',
      'Francês': 'Sœur'
    }),
    Question(portuguese: 'Olhos', translations: {
      'Inglês': 'Eyes',
      'Espanhol': 'Ojos',
      'Francês': 'Yeux'
    }),
    Question(portuguese: 'Mãos', translations: {
      'Inglês': 'Hands',
      'Espanhol': 'Manos',
      'Francês': 'Mains'
    }),
    Question(portuguese: 'Coração', translations: {
      'Inglês': 'Heart',
      'Espanhol': 'Corazón',
      'Francês': 'Cœur'
    }),
    Question(portuguese: 'Porta', translations: {
      'Inglês': 'Door',
      'Espanhol': 'Puerta',
      'Francês': 'Porte'
    }),
    Question(portuguese: 'Janela', translations: {
      'Inglês': 'Window',
      'Espanhol': 'Ventana',
      'Francês': 'Fenêtre'
    }),
    Question(portuguese: 'Cadeira', translations: {
      'Inglês': 'Chair',
      'Espanhol': 'Silla',
      'Francês': 'Chaise'
    }),
    Question(portuguese: 'Mesa', translations: {
      'Inglês': 'Table',
      'Espanhol': 'Mesa',
      'Francês': 'Table'
    }),
    Question(portuguese: 'Computador', translations: {
      'Inglês': 'Computer',
      'Espanhol': 'Computadora',
      'Francês': 'Ordinateur'
    }),
    Question(portuguese: 'Telefone', translations: {
      'Inglês': 'Phone',
      'Espanhol': 'Teléfono',
      'Francês': 'Téléphone'
    }),
    Question(
        portuguese: 'Cama',
        translations: {'Inglês': 'Bed', 'Espanhol': 'Cama', 'Francês': 'Lit'}),
    Question(portuguese: 'Roupa', translations: {
      'Inglês': 'Clothes',
      'Espanhol': 'Ropa',
      'Francês': 'Vêtements'
    }),
    Question(portuguese: 'Sapato', translations: {
      'Inglês': 'Shoe',
      'Espanhol': 'Zapato',
      'Francês': 'Chaussure'
    }),
    Question(portuguese: 'Peixe', translations: {
      'Inglês': 'Fish',
      'Espanhol': 'Pescado',
      'Francês': 'Poisson'
    }),
    Question(portuguese: 'Pássaro', translations: {
      'Inglês': 'Bird',
      'Espanhol': 'Pájaro',
      'Francês': 'Oiseau'
    }),
    Question(portuguese: 'Flor', translations: {
      'Inglês': 'Flower',
      'Espanhol': 'Flor',
      'Francês': 'Fleur'
    }),
    Question(portuguese: 'Montanha', translations: {
      'Inglês': 'Mountain',
      'Espanhol': 'Montaña',
      'Francês': 'Montagne'
    }),
    Question(portuguese: 'Rio', translations: {
      'Inglês': 'River',
      'Espanhol': 'Río',
      'Francês': 'Rivière'
    }),
    Question(
        portuguese: 'Mar',
        translations: {'Inglês': 'Sea', 'Espanhol': 'Mar', 'Francês': 'Mer'}),
    Question(portuguese: 'Praia', translations: {
      'Inglês': 'Beach',
      'Espanhol': 'Playa',
      'Francês': 'Plage'
    }),
    Question(portuguese: 'Barco', translations: {
      'Inglês': 'Boat',
      'Espanhol': 'Barco',
      'Francês': 'Bateau'
    }),
    Question(portuguese: 'Céu', translations: {
      'Inglês': 'Sky',
      'Espanhol': 'Cielo',
      'Francês': 'Ciel'
    }),
    Question(portuguese: 'Estrela', translations: {
      'Inglês': 'Star',
      'Espanhol': 'Estrella',
      'Francês': 'Étoile'
    }),
    Question(portuguese: 'Música', translations: {
      'Inglês': 'Music',
      'Espanhol': 'Música',
      'Francês': 'Musique'
    }),
    Question(portuguese: 'Chuva', translations: {
      'Inglês': 'Rain',
      'Espanhol': 'Lluvia',
      'Francês': 'Pluie'
    }),
    Question(portuguese: 'Fogo', translations: {
      'Inglês': 'Fire',
      'Espanhol': 'Fuego',
      'Francês': 'Feu'
    }),
    Question(portuguese: 'Vento', translations: {
      'Inglês': 'Wind',
      'Espanhol': 'Viento',
      'Francês': 'Vent'
    }),
  ];
}

/// Retorna uma lista aleatória de tamanho `n` sem repetição, a partir do seed.
List<Question> getRandomSeedSubset(int n) {
  final list = getSeedQuestions();
  list.shuffle(Random());
  return list.take(min(n, list.length)).toList();
}
