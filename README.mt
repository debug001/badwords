Badwords 是一款高性能敏感词替换 PHP 扩展。支持大小写敏感和不敏感过滤。支持 UTF-8 和 GBK/GB18030 两套编码体系。

* 如何使用

** Getting Started

There are three steps to doing a multiple-word-replacement with Boxwood:

1. Create a new boxwood resource.
2. Add the words to the resource that you want to replace.
3. Process the text in which you want to do the replacements.

For example:

<?php

if (boxwood_version("badwords1") < filemtime("wordsfb.php")) {
  boxwood_compile("badwords1", $bwtbl, filemtime("wordsfb.php"), 0);
}

boxwood_filter("badwords1", "My monkey ate some salad today.");

boxwood_delete("badwords1");

?>

This makes $replaced be the string "My m***** ate some s**** today." The string has been modified so that matching words get all but their first character replaced with "*" -- the third argument to boxwood_replace_text().

** Case Sensitivity

The first argument to boxwood_new() controls the case-sensitivity of the matching for replacement. Pass true to make matches case-sensitive, false to make them case-insensitive. The default (if no argument is provided) is to match case-insensitive.

** Multibyte Characters

boxwood understands US-ASCII and UTF-8. If you provide it with a string (either as a word to replace or as text to scan) that contains multibyte UTF-8 characters, they will be matched and replaced properly in both case-sensitive and case-insensitive mode. Note that the replacement character must be a single-byte US-ASCII character.

* Internals

The boxwood resource contains a trie which holds the list of words to replace. For example, if you add "one", "onto", and "bob" to the trie, then it looks like this:

root -> o -> n -> e
     |         \-> t -> o
     \-> b -> o -> b

If matching is to be done case-insensitively, the words are folded to lowercase before they're added to the trie. 

boxwood_replace_text(), walks through the text to replace byte by byte. If it sees a byte that is one of the bytes the root of the trie points too, then it attempts to traverse the trie, looking for children that correspond to subsequent bytes in the text to replace. 

This traversal ends in one of two possibilities. If the code gets to a point in the trie where it reaches a leaf node (one with no children), then it's found a correspondance between the text to replace and a word in the trie. So it replaces all but the first character of the word with the replacement byte.

If the code instead gets to a point where it reaches a non-leaf node that does not have a child corresponding to the next byte in the text, then what has appeared to be a match isn't. (E.g. "one" is on the list but the text to replace contains "onyx" -- the o and the n match but then the "n" node only has an "e" child, not a "y" child. At this point, the code goes back to the character after the initial match (e.g. the "n") and starts scanning again.

If matching is to be case insensitive, then the text walking happens against a copy of the text that has been folded to lowercase rather than the original text.

Multibyte characters are a little more complicated. Even though the comparisons can still happen byte-by-byte, replacements need to take into account character length. The structure of UTF-8 makes it fast to determine the length of character sequences and how to move forward and back in the strings.

* Future Directions

- Allow for multibyte replacement characters. Right now the replacement must be a single byte.
- Properly handle the situation when, in doing case folding the replacement character is a different length (in bytes) than the character being replaced. There are a handful of situations where this is true for UTF-8.
- Expose the binary versions of adding words and replacing byte sequences to PHP.
- Properly handle invalid UTF-8 sequences.
- Is it worth it to normalize the UTF-8 strings (see http://www.unicode.org/reports/tr15/) so that comparisons will succeed against alternative compositions?

* License

Badwords is Copyright 2011 HoopCHINA, Co., Ltd.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.