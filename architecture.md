# Architecture
The base unit of abstraction in the application are Controllers extending the
class ControllerBase. They have an well defined lifecycle, ie. are initialized
and disposed exactly once, and have exactly one owner at a time. They,
themselves, are made of internal state, other subcontrollers and
ValueListenables, which expose some part of the controller state at any given
time. They are constructed using map, bind and other operations, and also have
an well defined lifecycle, allowing complex usages like streams, which need to
get cleaned up. The datatypes on this app are generated using adt_generator,
and are products, sums, records, or opaques. This allows very rich typesafe
apis. The chosen database was hive, an sinple key-value store. For storing
undoable stuff, the doubly linked event sourced model from utils was used,
allowing an simple api for this complex usecase. The sudoku generation is made
with libsudoku on another isolate for maximum performance and best ux. The ui
is made with the material_widgets package, implementing the material design 3
spec.

# Directory structure

## Module
Modules are free controllers (Not subcontrollers of another controller), which
have no associated view, and are reused across multiple other controllers.

### Base
The base module implements the low level api for interacting with a sudoku game
and while storing it in the database. It exposes an SudokuAppState,
whether or not it can undo, and allows undoing, setting a number, setting a
possibility, resetting the board and clearing a tile.

### Theme
The theme module controls the theming across the application. It exposes the
currently enabled theme, the user themes, every theme, and stores this in a
database.

### Animation
The animation module controls the animation options across the application.
It exposes the current animation options and speed, and allows modifying both,
while storing in a database.

## Navigation
Contains the routing stuff for the application.

## Sudoku Generation
The sudoku_generation subdirectory is responsible for generating sudokus in an
non-blocking way. To do so, it has an streaming sudoku generation function,
which uses some blocking primitives. This function is then ran in an isolate,
if possible, and on the main thread otherwise. The blocking primitives can be
from two sources: libsudoku ffi bindings, or an wrapper api from sudoku_core
from the old application. I plan on writing an webworker implementation of the
streaming version but this is not ready for now.

## Util
Some misc utils.

## View
An view is an flutter widget that is associated to an viewmodel. Each viewmodel
has an single view, otherwise the business logic would become complicated.
The widgets may need to create controllers, and when they do so, they own the
controller, and, therefore, are responsible for the initialization and
disposal. This is normally accomplished using an widget from
package:value_notifier that does so automatically, using the State.dispose
method.

## Viewmodel
An viewmodel is an controller that has an associated view. They normally talk
with other modules or viewmodels via value listenables.

### Create Theme
The create theme viewmodel controls the create theme dialog. It exposes the
current created theme, it's name, it's primary seed, it's secondary seed, it's
background, and allows modifying those.

### Home
The home viewmodel controls the home view. It exposes whether or not we can
continue, the current side, the current difficulty, and stores those values in
a database.

### Preferences dialog
The preferences dialog viewmodel controls the preferences dialog.
It has two subcontrollers, one for managing the theme preferences and one for
managing the animation preferences

#### Theme
It exposes the theme that will be set and the user theme list that will be set,
and it allows adding new themes and changing the current theme.

#### Animation
It exposes the animation options that will be set, and it allows changing the
text animation options, selection animation options and animation speed.

### Sudoku Board
The sudoku board viewmodel controls the sudoku board view. It is responsible for
managing the board navigation pattern and has three
subcontrollers, one for managing the actions bar, one for managing the keypad
and one for managing the board itself.

### Sudoku generation
The sudoku generation viewmodel controls the sudoku generation view. It is
resposible for generating the sudoku, using the streaming sudoku generation api,
and the view is responsible for creating an sudoku controller using this
generated board.

## Widget
The widgets in this directory may or may not be reusable and dont have any
controller associated with them.

