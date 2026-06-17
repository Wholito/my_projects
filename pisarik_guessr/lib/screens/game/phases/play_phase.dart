import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/utils/item_helper.dart';
import 'package:pisarik_guessr/screens/game/widgets/input_area.dart';
import 'package:pisarik_guessr/screens/game/widgets/all_items_dialog.dart';
import 'package:pisarik_guessr/screens/game/widgets/word_suggestions_dialog.dart';
import 'package:confetti/confetti.dart';
import '../../../models/character.dart';
import '../../../models/game_item.dart';

class PlayPhase extends StatefulWidget {
  const PlayPhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  State<PlayPhase> createState() => _PlayPhaseState();
}

class _PlayPhaseState extends State<PlayPhase> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _descScrollController = ScrollController();
  final ScrollController _guessScrollController = ScrollController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _textController.dispose();
    _descScrollController.dispose();
    _guessScrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppState>().user!.id;
    final game = widget.game;
    final isDescriber = game.describerId == userId;
    final isGuesser = game.guesserId == userId;
    final gameService = context.read<AppState>().game;

    final selectedObject = isDescriber ? ItemHelper.getSelectedObject(game) : null;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              if (game.currentLetter != null)
                _LetterBanner(letter: game.currentLetter!),
              if (isDescriber && selectedObject != null)
                _SelectedObjectCard(object: selectedObject, isItemMode: game.gameMode == GameMode.items),
              Expanded(
                child: _MessagesList(
                  gameId: widget.gameId,
                  userId: userId,
                  gameService: gameService,
                  descScrollController: _descScrollController,
                  guessScrollController: _guessScrollController,
                  game: game,
                  onCorrectGuess: () {
                    if (_confettiController.state == ConfettiControllerState.stopped) {
                      _confettiController.play();
                    }
                  },
                ),
              ),
              InputArea(
                game: game,
                gameId: widget.gameId,
                isDescriber: isDescriber,
                isGuesser: isGuesser,
                textController: _textController,
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 50,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterBanner extends StatelessWidget {
  const _LetterBanner({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: Text(
          'Буква: «${letter.toUpperCase()}»',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class _SelectedObjectCard extends StatelessWidget {
  const _SelectedObjectCard({required this.object, required this.isItemMode});
  final Object object;
  final bool isItemMode;

  @override
  Widget build(BuildContext context) {
    final imageAsset = isItemMode
        ? (object as GameItem).imageAsset
        : (object as GameCharacter).imageAsset;
    final name = isItemMode
        ? (object as GameItem).name
        : (object as GameCharacter).name;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: ModalRoute.of(context)!.animation!, curve: Curves.easeOut),
      ),
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  width: 48,
                  height: 48,
                  image: AssetImage(imageAsset) as ImageProvider,
                  errorBuilder: (_, __, ___) => const Icon(Icons.question_mark, size: 48),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Вы загадали: $name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesList extends StatefulWidget {
  const _MessagesList({
    required this.gameId,
    required this.userId,
    required this.gameService,
    required this.descScrollController,
    required this.guessScrollController,
    required this.game,
    required this.onCorrectGuess,
  });

  final String gameId;
  final String userId;
  final dynamic gameService;
  final ScrollController descScrollController;
  final ScrollController guessScrollController;
  final GameSession game;
  final VoidCallback onCorrectGuess;

  @override
  State<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<_MessagesList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GameMessage>>(
      stream: widget.gameService.watchMessages(widget.gameId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allMessages = snapshot.data!;
        final descriptions = <GameMessage>[];
        final guesses = <GameMessage>[];
        for (final msg in allMessages) {
          if (msg.isGuess) guesses.add(msg);
          else descriptions.add(msg);
        }

        final hasCorrect = guesses.any((m) => m.isCorrect && m.senderId == widget.game.guesserId);
        if (hasCorrect) {
          WidgetsBinding.instance.addPostFrameCallback((_) => widget.onCorrectGuess());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(widget.descScrollController);
          _scrollToBottom(widget.guessScrollController);
        });

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MessageColumn(
              title: 'Описания',
              messages: descriptions,
              userId: widget.userId,
              scrollController: widget.descScrollController,
            ),
            _MessageColumn(
              title: 'Догадки',
              messages: guesses,
              userId: widget.userId,
              scrollController: widget.guessScrollController,
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }
}

class _MessageColumn extends StatelessWidget {
  const _MessageColumn({
    required this.title,
    required this.messages,
    required this.userId,
    required this.scrollController,
  });

  final String title;
  final List<GameMessage> messages;
  final String userId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == userId;
                return _ChatMessageWidget(
                  message: msg,
                  isMe: isMe,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  const _ChatMessageWidget({required this.message, required this.isMe});

  final GameMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isCorrect
                  ? Colors.green.shade800
                  : (isMe ? Theme.of(context).colorScheme.primary : const Color(0xFF2A2A4A)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    const Text(
                      'Соперник',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  Text(
                    message.text,
                    softWrap: true,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTime(message.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}