import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> _deck = [];
  final List<String> _playerHand = [];
  final List<String> _dealerHand = [];
  final Random _random = Random();
  bool _gameOver = false;
  String _message = "¡Tu turno!";
  int _playerWins = 0;
  int _dealerWins = 0;
  bool _buttonsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeDeck();
    _dealInitialCards();
  }

  // Inicializar la baraja
  void _initializeDeck() {
    const suits = ['Oros', 'Copas', 'Espadas', 'Bastos'];
    const ranks = ['1', '2', '3', '4', '5', '6', '7', '10', '11', '12'];
    for (var suit in suits) {
      for (var rank in ranks) {
        _deck.add('$rank de $suit');
      }
    }
    _deck.shuffle(_random);
  }

  // Repartir las cartas iniciales
  void _dealInitialCards() {
    _playerHand.add(_drawFromDeck());
    _dealerHand.add(_drawFromDeck());
  }

  // Sacar una carta de la baraja
  String _drawFromDeck() {
    return _deck.removeAt(0);
  }

  // Calcular el puntaje de una mano
  double _calculateScore(List<String> hand) {
    double score = 0;
    for (var card in hand) {
      String rank = card.split(' ')[0];
      if (rank == '10' || rank == '11' || rank == '12') {
        score += 0.5;
      } else {
        score += double.parse(rank);
      }
    }
    return score;
  }

  // Método para pedir carta
  void _playerHit() {
    if (!_gameOver && _buttonsEnabled) {
      setState(() {
        _playerHand.add(_drawFromDeck());
        if (_calculateScore(_playerHand) > 7.5) {
          _message = "¡Te pasaste! ¡Perdiste!";
          _dealerWins++;
          _gameOver = true;
          _endRound();
        }
      });
    }
  }

  // Método para plantarse
  void _playerStand() {
    if (!_gameOver && _buttonsEnabled) {
      setState(() {
        while (_calculateScore(_dealerHand) <= _calculateScore(_playerHand) &&
            _calculateScore(_dealerHand) <= 7.5) {
          _dealerHand.add(_drawFromDeck());
        }

        double playerScore = _calculateScore(_playerHand);
        double dealerScore = _calculateScore(_dealerHand);

        if (dealerScore > 7.5 || playerScore > dealerScore) {
          _message = "¡Ganaste!";
          _playerWins++;
        } else if (playerScore < dealerScore) {
          _message = "¡Perdiste!";
          _dealerWins++;
        } else {
          _message = "¡Empate!";
        }

        if (_playerWins == 5 || _dealerWins == 5) {
          _gameOver = true;
          _endRound();
        } else {
          _buttonsEnabled = false; // Deshabilitar botones después de plantarse
          _endRound();
        }
      });
    }
  }

  // Finalizar la ronda y mostrar el mensaje
  void _endRound() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_playerWins == 5 || _dealerWins == 5) {
        _showEndDialog();
      } else {
        _restartGame();
      }
    });
  }

  // Reiniciar el juego
  void _restartGame() {
    setState(() {
      _deck.clear();
      _playerHand.clear();
      _dealerHand.clear();
      _gameOver = false;
      _buttonsEnabled = true; // Habilitar botones para la siguiente ronda
      _message = "¡Tu turno!";
      _initializeDeck();
      _dealInitialCards();
    });
  }

  // Mostrar el diálogo al finalizar el juego
  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Juego Terminado"),
          content: Text(
            _playerWins == 5
                ? "¡Has ganado 5 partidas! Felicitaciones."
                : "La máquina ganó 5 partidas. ¡Mejor suerte la próxima vez!"),
          actions: [
            TextButton(
              child: const Text("Volver al inicio"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Regresar al inicio
              },
            ),
            TextButton(
              child: const Text("Reiniciar juego"),
              onPressed: () {
                _playerWins = 0;
                _dealerWins = 0;
                Navigator.pop(context);
                _restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  // Construir la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partida"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHand("Cartas de la máquina", _dealerHand, !_gameOver),
          const SizedBox(height: 20),
          _buildHand("Tus cartas", _playerHand, false),
          const SizedBox(height: 20),
          Text("Mensaje: $_message", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          _buildActions(),
          const SizedBox(height: 20),
          _buildScoreboard(),
        ],
      ),
    );
  }

  // Construir las manos de los jugadores
  Widget _buildHand(String title, List<String> hand, bool hideFirstCard) {
    String displayCards = hideFirstCard && hand.isNotEmpty
        ? '🂠 ${hand.sublist(1).join(", ")}'
        : hand.join(", ");

    double score = hideFirstCard && hand.isNotEmpty
        ? _calculateScore(hand.sublist(1))
        : _calculateScore(hand);

    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        Text(
          displayCards,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        Text("Puntuación: ${score.toStringAsFixed(1)}",
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  // Construir las acciones (botones de pedir carta y plantarse)
  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _buttonsEnabled ? _playerHit : null, // Deshabilitar si no están habilitados
          child: const Text("Pedir carta"),
        ),
        ElevatedButton(
          onPressed: _buttonsEnabled ? _playerStand : null, // Deshabilitar si no están habilitados
          child: const Text("Plantarse"),
        ),
      ],
    );
  }

  // Mostrar el marcador de victorias
  Widget _buildScoreboard() {
    return Column(
      children: [
        Text("Victorias del jugador: $_playerWins",
            style: const TextStyle(fontSize: 16)),
        Text("Victorias de la máquina: $_dealerWins",
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
