# ThemeService használat

A ThemeService egy Riverpod `StateNotifier`, amely a választott FlexColorScheme
indexét (`schemeIndex`) és a sötét mód állapotát (`isDark`) tárolja.
Az alábbi példa bemutatja, hogyan lehet egy widgetből figyelni és módosítani a
state-et.

```dart
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServiceProvider);
    return Switch(
      value: theme.isDark,
      onChanged: (_) =>
          ref.read(themeServiceProvider.notifier).toggleDarkMode(),
    );
  }
}
```

A skin váltásához hívd meg a `toggleTheme()` vagy `setScheme(index)` metódust a
`themeServiceProvider.notifier`-en keresztül.

## main.dart integráció

A fő alkalmazásban a `MaterialApp` theme paramétereit is a ThemeService állapota generálja
a `ThemeBuilder` segítségével:

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeServiceProvider);
    return MaterialApp.router(
      theme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.light,
      ),
      darkTheme: buildTheme(
        scheme: FlexScheme.values[theme.schemeIndex],
        brightness: Brightness.dark,
      ),
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
```
