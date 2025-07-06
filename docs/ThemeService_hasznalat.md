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
