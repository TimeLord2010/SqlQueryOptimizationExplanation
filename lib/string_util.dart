List<String> splitOnce (String text, Pattern separator) {
  var index = text.indexOf(separator);
  if (index < 0) return [text];
  var part1 = text.substring(0, index);
  var part2 = text.substring(index+1);
  return [part1, part2];
}