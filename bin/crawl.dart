import 'dart:io';

import 'package:string_normalizer/src/crawler.dart';
import 'package:string_normalizer/src/data/local.dart';
import 'package:string_normalizer/src/utils.dart';

void main(List<String> args) async {
  final crawler = Crawler();

  print('Crawling new data..');
  final map = await crawler.crawl();
  final flattedMap = flatMap(map);

  if (_mapEquals(flattedMap, flatMap(data))) {
    print('The local data is up to date');
    print('Done');
    return;
  }

  print('There is an available update');

  final file = File('lib/src/data/local.dart');

  // Backup
  if (file.existsSync()) {
    final backupedFile = File('lib/src/data/local.bak.dart');
    print('Backuping to `lib/data/local.bak.dart`..');
    backupedFile.writeAsStringSync(file.readAsStringSync());
  }

  print('Writing the new data to `lib/data/local.dart`..');

  // Write new file
  final string = '''
// Copyright (c) 2023, Lam Thanh Nhan. All rights reserved. Use of this source code
// is governed by a MIT license that can be found in the LICENSE file.
//
// Generated by the crawler. Run `dart run string_normalizer:crawl` to re-generate.

const data =  ''';
  file.writeAsStringSync('$string${crawler.crawledDataToString(map)}');
  Process.runSync('dart', ['format', file.absolute.path]);

  print('Done');
}

bool _mapEquals(Map<int, String> map1, Map<int, String> map2) {
  if (map1.keys.length != map2.keys.length) return false;

  for (int k in map1.keys) {
    if (!map2.containsKey(k)) return false;
    if (map1[k] != map2[k]) return false;
  }

  return true;
}
