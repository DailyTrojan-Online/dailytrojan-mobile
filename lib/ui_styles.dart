import 'package:flutter/material.dart';

abstract final class UiStyles {
  static TextStyle heading(ThemeData theme, {double? fontSize}) =>
      theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

  static TextStyle subHeading(ThemeData theme) =>
      theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "SourceSerif4",
      );
  static TextStyle headingMedium(ThemeData theme) =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
      );
  static TextStyle headingSmall(ThemeData theme) =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
      );

  static TextStyle headingMagazine(ThemeData theme) =>
      theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "ManufacturingConsent",
        height: .8,
      );




  static TextStyle body(ThemeData theme) =>
      theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 16.0,
        decoration: TextDecoration.none,
        fontFamily: "SourceSerif4",
      );


  static TextStyle metadata(ThemeData theme) =>
      theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 13.0,
        fontFamily: "Inter",
      );


  static TextStyle outlinedButton(ThemeData theme) =>
      theme.textTheme.labelLarge!.copyWith(
        fontFamily: "Inter",
        color: theme.colorScheme.onPrimaryFixed,
        fontWeight: FontWeight.bold,
      );

      
  static TextStyle filledButton(ThemeData theme) =>
      theme.textTheme.labelLarge!.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold,
      );

  static TextTheme appTextTheme(ThemeData theme) =>
      theme.textTheme.apply(fontFamily: "Inter");
}
