# BrandColors használat

Egyedi márka színek elérése widgetből:

```dart
final colors = Theme.of(context).extension<BrandColors>()!;
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [colors.gradientStart, colors.gradientEnd],
    ),
  ),
);
```
