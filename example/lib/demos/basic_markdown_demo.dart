// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../shared/dropdown_menu.dart';
import '../shared/markdown_demo_widget.dart';
import '../shared/markdown_extensions.dart';

// ignore_for_file: public_member_api_docs

const String _notes = """
# Basic Markdown Demo
---
The Basic Markdown Demo shows the effect of the four Markdown extension sets
on formatting basic and extended Markdown tags.

## Overview

The Dart [markdown](https://pub.dev/packages/markdown) package parses Markdown
into HTML. The flutter_markdown package builds on this package using the
abstract syntax tree generated by the parser to make a tree of widgets instead
of HTML elements.

The markdown package supports the basic block and inline Markdown syntax
specified in the original Markdown implementation as well as a few Markdown
extensions. The markdown package uses extension sets to make extension
management easy. There are four pre-defined extension sets; none, Common Mark,
GitHub Flavored, and GitHub Web. The default extension set used by the
flutter_markdown package is GitHub Flavored.

The Basic Markdown Demo shows the effect each of the pre-defined extension sets
has on a test Markdown document with basic and extended Markdown tags. Use the
Extension Set dropdown menu to select an extension set and view the Markdown
widget's output.

## Comments

Since GitHub Flavored is the default extension set, it is the initial setting
for the formatted Markdown view in the demo.
""";

class BasicMarkdownDemo extends StatefulWidget implements MarkdownDemoWidget {
  const BasicMarkdownDemo({Key? key}) : super(key: key);

  static const String _title = 'Basic Markdown Demo';

  @override
  String get title => BasicMarkdownDemo._title;

  @override
  String get description => 'Shows the effect the four Markdown extension sets '
      'have on basic and extended Markdown tagged elements.';

  @override
  Future<String> get data =>
      rootBundle.loadString('assets/markdown_test_page.md');

  @override
  Future<String> get notes => Future<String>.value(_notes);

  @override
  _BasicMarkdownDemoState createState() => _BasicMarkdownDemoState();
}

class _BasicMarkdownDemoState extends State<BasicMarkdownDemo> {
  MarkdownExtensionSet _extensionSet = MarkdownExtensionSet.githubFlavored;

  final Map<String, MarkdownExtensionSet> _menuItems =
      Map<String, MarkdownExtensionSet>.fromIterables(
    MarkdownExtensionSet.values.map((MarkdownExtensionSet e) => e.displayTitle),
    MarkdownExtensionSet.values,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: <Widget>[
              DropdownMenu<MarkdownExtensionSet>(
                items: _menuItems,
                label: 'Extension Set:',
                initialValue: _extensionSet,
                onChanged: (MarkdownExtensionSet? value) {
                  if (value != _extensionSet) {
                    setState(() {
                      _extensionSet = value!;
                    });
                  }
                },
              ),
              Expanded(
                child: Markdown(
                  key: Key(_extensionSet.name),
                  data: snapshot.data!,
                  imageDirectory: 'https://raw.githubusercontent.com',
                  extensionSet: _extensionSet.value,
                  builders: <String, MarkdownElementBuilder>{
                    'h1': CenteredHeaderBuilder(),
                    'h6': CenteredHeaderBuilder(),
                    'pre': PreBuilder(),
                    'code': CodeBuilder(),
                  },
                  onTapLink: (String text, String? href, String title) =>
                      linkOnTapHandler(context, text, href, title),
                ),
              ),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // Handle the link. The [href] in the callback contains information
  // from the link. The url_launcher package or other similar package
  // can be used to execute the link.
  Future<void> linkOnTapHandler(
    BuildContext context,
    String text,
    String? href,
    String title,
  ) async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) =>
          _createDialog(context, text, href, title),
    );
  }

  Widget _createDialog(
          BuildContext context, String text, String? href, String title) =>
      AlertDialog(
        title: const Text('Reference Link'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'See the following link for more information:',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                'Link text: $text',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link destination: $href',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 8),
              Text(
                'Link title: $title',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      );
}

class CenteredHeaderBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: preferredStyle),
      ],
    );
  }
}

String language = '';

class CodeBuilder extends MarkdownElementBuilder {
  @override
  void visitElementBefore(md.Element element) {
    if (element.attributes['class'] != null) {
      language = element.attributes['class']!.replaceAll('language-', '');
    }
    super.visitElementBefore(element);
  }
}

class PreBuilder extends MarkdownElementBuilder {
  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return HighlightView(
      // The original code to be highlighted
      text.text,

      // Specify language
      // It is recommended to give it a value for performance
      // 这里language不能为空，否则会报错。如果需要自动识别语言，需要修改项目flutter_highlight
      language: language,
      // Specify highlight theme
      // All available themes are listed in `themes` folder
      theme: githubTheme,

      // Specify padding
      padding: EdgeInsets.all(12),

      // Specify text style
      // textStyle: TextStyle(
      //   fontFamily: 'My awesome monospace font',
      //   fontSize: 16,
      // ),
    );
  }
}
