import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'game_theme.dart';

enum GamePhase {
  waitingForPlayer,
  themeSelection,
  modeSelection,
  roleAssignment,
  characterSelection,
  playing,
  finished,
}

enum PlayerRole {
  describer,
  guesser,
}

class GameSession {
  const GameSession({
    required this.id,
    required this.hostId,
    this.guestId,
    this.theme,
    this.phase = GamePhase.waitingForPlayer,
    this.describerId,
    this.guesserId,
    this.characterId,
    this.currentLetter,
    this.wordCount = 0,
    this.guessCount = 0,
    this.hostThemeVote,
    this.guestThemeVote,
    this.winnerId,
    this.correctGuess,
    this.gameMode,
    this.pussyMode = false,
    this.guessedItems = const [],
  });

  final String id;
  final String hostId;
  final String? guestId;
  final GameTheme? theme;
  final GamePhase phase;
  final String? describerId;
  final String? guesserId;
  final String? characterId;
  final String? currentLetter;
  final int wordCount;
  final int guessCount;
  final String? hostThemeVote;
  final String? guestThemeVote;
  final String? winnerId;
  final String? correctGuess;
  final GameMode? gameMode;
  final bool pussyMode;
  final List<String> guessedItems;

  bool get isFull => guestId != null;

  String? roleFor(String userId) {
    if (describerId == userId) return 'describer';
    if (guesserId == userId) return 'guesser';
    return null;
  }

  PlayerRole? playerRoleFor(String userId) {
    if (describerId == userId) return PlayerRole.describer;
    if (guesserId == userId) return PlayerRole.guesser;
    return null;
  }

  factory GameSession.fromMap(String id, Map<String, dynamic> data) {
    return GameSession(
      id: id,
      hostId: data['hostId'] as String,
      guestId: data['guestId'] as String?,
      theme: GameTheme.fromId(data['theme'] as String?),
      phase: GamePhase.values.firstWhere(
            (p) => p.name == data['phase'],
        orElse: () => GamePhase.waitingForPlayer,
      ),
      describerId: data['describerId'] as String?,
      guesserId: data['guesserId'] as String?,
      characterId: data['characterId'] as String?,
      currentLetter: data['currentLetter'] as String?,
      wordCount: data['wordCount'] as int? ?? 0,
      guessCount: data['guessCount'] as int? ?? 0,
      hostThemeVote: data['hostThemeVote'] as String?,
      guestThemeVote: data['guestThemeVote'] as String?,
      winnerId: data['winnerId'] as String?,
      correctGuess: data['correctGuess'] as String?,
      gameMode: GameMode.fromId(data['gameMode'] as String?),
      pussyMode: data['pussyMode'] as bool? ?? false,
      guessedItems: (data['guessedItems'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
    'hostId': hostId,
    'guestId': guestId,
    'theme': theme?.id,
    'phase': phase.name,
    'describerId': describerId,
    'guesserId': guesserId,
    'characterId': characterId,
    'currentLetter': currentLetter,
    'wordCount': wordCount,
    'guessCount': guessCount,
    'hostThemeVote': hostThemeVote,
    'guestThemeVote': guestThemeVote,
    'winnerId': winnerId,
    'correctGuess': correctGuess,
    'gameMode': gameMode?.id,
    'pussyMode': pussyMode,
    'guessedItems': guessedItems,
  };

  GameSession copyWith({
    String? guestId,
    GameTheme? theme,
    GamePhase? phase,
    String? describerId,
    String? guesserId,
    String? characterId,
    String? currentLetter,
    int? wordCount,
    int? guessCount,
    String? hostThemeVote,
    String? guestThemeVote,
    String? winnerId,
    String? correctGuess,
    GameMode? gameMode,
    bool? pussyMode,
    List<String>? guessedItems
  }) {
    return GameSession(
      id: id,
      hostId: hostId,
      guestId: guestId ?? this.guestId,
      theme: theme ?? this.theme,
      phase: phase ?? this.phase,
      describerId: describerId ?? this.describerId,
      guesserId: guesserId ?? this.guesserId,
      characterId: characterId ?? this.characterId,
      currentLetter: currentLetter ?? this.currentLetter,
      wordCount: wordCount ?? this.wordCount,
      guessCount: guessCount ?? this.guessCount,
      hostThemeVote: hostThemeVote ?? this.hostThemeVote,
      guestThemeVote: guestThemeVote ?? this.guestThemeVote,
      winnerId: winnerId ?? this.winnerId,
      correctGuess: correctGuess ?? this.correctGuess,
      gameMode: gameMode ?? this.gameMode,
      pussyMode: pussyMode ?? this.pussyMode,
      guessedItems: guessedItems ?? this.guessedItems,
    );
  }
}

class GameMessage {
  const GameMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isGuess = false,
    this.isCorrect = false,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isGuess;
  final bool isCorrect;

  factory GameMessage.fromMap(String id, Map<String, dynamic> data) {
    return GameMessage(
      id: id,
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      createdAt: _parseTimestamp(data['createdAt']),
      isGuess: data['isGuess'] as bool? ?? false,
      isCorrect: data['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
    'isGuess': isGuess,
    'isCorrect': isCorrect,
  };
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}