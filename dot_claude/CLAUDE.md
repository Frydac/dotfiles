# Path output formatting

When referencing a source location, format it as `path:line` (or
`path:line:column` when you know the column) so it's clickable via my kitty
`regex` hints (ctrl+shift+m, see ~/notes/kitty.md):

- Use an absolute path (`/home/emile/...`) or a path relative to the cwd.
- Make sure there is white space before and after the path.
- Never use `~`-prefixed paths — kitty/nvr won't expand them.
- Put line (and optional column) after single colons: `src/foo.c:42` or
  `src/foo.c:42:7`. No space around the colons.
- Don't write it as prose like `foo.c (line 42)` — that won't match the hint.
