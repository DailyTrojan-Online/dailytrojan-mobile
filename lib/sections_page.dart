import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/main_section_route.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Section {
  final String title;
  final int id;
  Section({required this.title, required this.id});
}

class SectionHeirarchy {
  final Section mainSection;
  final List<Section> subsections;
  SectionHeirarchy({required this.mainSection, required this.subsections});
}

List<SectionHeirarchy> Sections = [
  SectionHeirarchy(
      mainSection: Section(title: "News", id: NewsID),
      subsections: [
        Section(title: "City", id: 27273),
        Section(title: "USG", id: 33500),
        Section(title: "Student Health", id: 33503),
        Section(title: "Science", id: 33501),
        Section(title: "Labor", id: 33502),
        Section(title: "Finance", id: 33504),
        Section(title: "Housing", id: 16940),
        Section(title: "Sustainability", id: 34536),
      ]),
  SectionHeirarchy(
      mainSection:
          Section(title: "Arts & Entertainment", id: ArtsEntertainmentID),
      subsections: [
        Section(title: "Culture", id: 30770),
        Section(title: "Film", id: 8),
        Section(title: "Food", id: 27516),
        Section(title: "Games", id: 134),
        Section(title: "Literature", id: 27508),
        Section(title: "Music", id: 48),
        Section(title: "Reviews", id: 101),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Sports", id: SportsID),
      subsections: [
        Section(title: "Baseball", id: 92),
        Section(title: "Basketball", id: 85),
        Section(title: "Football", id: 7),
        Section(title: "Soccer", id: 262),
        Section(title: "Tennis", id: 84),
        Section(title: "Volleyball", id: 271),
        Section(title: "Water Polo", id: 164),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Opinion", id: OpinionID),
      subsections: [
        Section(title: "From The Editors", id: 891),
        Section(title: "Letters to the Editor", id: 16943),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Magazine", id: 33530), subsections: []),
];

class SectionsPage extends StatefulWidget {
  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);

    final mainSectionStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold);
    final subSectionStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
          title: Text(
                  "Sections",
                  style: headerStyle,
                ),
        backButton: false,
        children: [
          for (int i = 0; i < Sections.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0)
                          .add(horizontalContentPadding),
                      child: Text(
                        Sections[i].mainSection.title,
                        style: mainSectionStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (Sections[i].subsections.isNotEmpty) {
                      appState.setMainSection(Sections[i]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MainSectionRoute()),
                      );
                    } else {
                      appState.setSection(Sections[i].mainSection);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SectionRoute()),
                      );
                    }
                  },
                ),
                if (!(Sections[i].subsections.isEmpty &&
                    i >= Sections.length - 1))
                  Padding(
                    padding: horizontalContentPadding,
                    child: Divider(thickness: 2, height: 2),
                  ),
                for (int j = 0; j < Sections[i].subsections.length; j++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10.0)
                                    .add(horizontalContentPadding),
                            child: Text(
                              Sections[i].subsections[j].title,
                              style: subSectionStyle,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        onTap: () {
                          appState.setSection(Sections[i].subsections[j]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SectionRoute()),
                          );
                        },
                      ),
                      if (j < Sections[i].subsections.length - 1)
                        Padding(
                          padding: horizontalContentPadding,
                          child: Divider(height: 1),
                        ),
                    ],
                  ),
                if (Sections[i].subsections.isNotEmpty &&
                    i < Sections.length - 1)
                  Padding(
                    padding: horizontalContentPadding,
                    child: Divider(thickness: 2, height: 2),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
