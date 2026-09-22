# Pisarick Guessr

A multiplayer character guessing game built with Flutter and Firebase.

Players can create game sessions with friends, choose a game theme and compete by guessing characters from games such as Brawl Stars and Dota 2.

## Features

* User registration and authentication
* Player profiles
* Friend system
* Multiplayer game sessions
* Game invitations
* Game themes
* Character selection
* Character guessing
* Role-based gameplay
* Score calculation
* Real-time game state synchronization
* Brawl Stars character database
* Dota 2 character database
* Russian and English character names
* Firebase Authentication
* Cloud Firestore
* Cross-platform Flutter application

## Tech Stack

### Frontend

* Flutter
* Dart
* Material Design
* Google Fonts

### State Management

* Provider
* ChangeNotifier

### Backend and Database

* Firebase Authentication
* Cloud Firestore

### Architecture

* Repository Pattern
* Service Layer
* Provider-based state management
* Separation of UI and business logic
* Model-based data structures

### Development Tools

* Android Studio
* Git
* GitHub
* Firebase
* Flutter DevTools

---

## Game Flow

The game is divided into several phases:

```text
Waiting for Player
        |
        v
Theme Selection
        |
        v
Role Assignment
        |
        v
Character Selection
        |
        v
Playing
        |
        v
Finished
```

Each phase represents a separate stage of the multiplayer game.

---

## Game Roles

Players can receive different roles during a game.

### Describer

The describer receives the selected character and provides clues to the other player.

### Guesser

The guesser tries to identify the character based on the available clues.

The roles are assigned as part of the game flow.

---

## Character System

The application uses a unified character model for different game themes.

Character data is separated by game:

```text
data/
  characters/
    brawl_stars_characters.dart
    dota2_characters.dart
```

The application can work with character names and aliases in different languages.

Guess validation normalizes user input before comparison, including:

* Removing unnecessary whitespace
* Converting text to lowercase
* Normalizing "ё" and "е"
* Supporting aliases

---

## Game Architecture

The application uses a layered structure to keep UI, state management and backend communication separated.

```text
UI
 |
 v
AppState / State Management
 |
 v
Services
 |
 v
Repositories
 |
 v
Firebase
 |
 v
Cloud Firestore
```

The main application layers include:

* Screens
* Widgets
* Providers
* Services
* Repositories
* Models
* Data
* Utilities

---

## Project Structure

```text
lib/
|
├── main.dart
├── app_theme.dart
├── firebase_options.dart
|
├── data/
│   ├── character_repository.dart
│   └── characters/
│       ├── brawl_stars_characters.dart
│       └── dota2_characters.dart
|
├── models/
│   ├── app_user.dart
│   ├── game_character.dart
│   ├── game_session.dart
│   └── game_theme.dart
|
├── providers/
│   └── app_state.dart
|
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── game/
│   │   └── game_flow_screen.dart
│   │
│   └── home/
│       └── home_screen.dart
|
├── services/
│   ├── auth_service.dart
│   ├── friends_service.dart
│   └── game_service.dart
|
├── utils/
│   ├── russian_alphabet.dart
│   └── scoring.dart
|
└── widgets/
    └── game_icon.dart
```

---

## Main Components

### Authentication

`AuthService` handles user authentication through Firebase Authentication.

Main functionality:

* Registration
* Login
* Logout
* Authentication state

---

### Friends

`FriendsService` is responsible for the player's friend system.

The application stores friendship information in Cloud Firestore and loads friend profiles for the current user.

---

### Game Service

`GameService` manages the game session and multiplayer game flow.

It is responsible for operations related to:

* Game creation
* Game sessions
* Player participation
* Game phases
* Character selection
* Game state
* Score calculation

---

### Character Repository

`CharacterRepository` provides access to character data.

Character data is separated from the UI and game logic so that different game themes can use the same character model.

---

## Models

The application uses dedicated models for the main entities.

### AppUser

Represents an application user.

Contains information such as:

* User ID
* Email
* Display name
* Friend code

### GameCharacter

Represents a character available in the game.

Contains:

* Character ID
* Name
* Aliases
* Image asset
* Game/theme information

### GameSession

Represents a multiplayer game session.

Contains information about:

* Players
* Game state
* Current phase
* Selected theme
* Roles
* Character
* Score

### GameTheme

Represents a game category available for a session.

---

## Firebase

The project uses Firebase as the backend platform.

### Firebase Authentication

Used for:

* User registration
* Login
* Logout
* Authentication state

### Cloud Firestore

Used for:

* User data
* Friends
* Game sessions
* Multiplayer state
* Game-related data

---

## State Management

The application uses Provider and ChangeNotifier for application state.

The main application state is initialized from `AppState`.

The state layer is responsible
