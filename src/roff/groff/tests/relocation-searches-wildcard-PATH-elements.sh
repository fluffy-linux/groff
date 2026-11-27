#!/sw/bash/bin/bash
#
# Check that groff, run by a bare name, finds itself in a PATH whose
# elements have a '*' component, as execvp finds it, and relocates its
# bin directory from there.  groff puts that directory first in the
# PATH it gives troff, so a stand-in troff that prints its PATH shows
# which prefix groff chose.

groff="${abs_top_builddir:-.}/groff"
fontpath="${abs_top_builddir:-.}/font:${abs_top_srcdir:-.}/font"

work=$(mktemp -d) || exit 99
trap 'rm -rf "$work"' EXIT

# Elements in glob order: a/bin has no groff, b/bin and c/bin both do.
mkdir -p "$work/a/bin" "$work/b/bin" "$work/c/bin" || exit 99
for d in b c
do
    ln -s "$groff" "$work/$d/bin/groff" || exit 99
    printf '%s\n' '#!/sw/bash/bin/bash' 'printf "%s\n" "$PATH"' \
        > "$work/$d/bin/troff" || exit 99
    chmod +x "$work/$d/bin/troff" || exit 99
done

# Not from the build tree: groff would find itself in the current
# directory first.
cd "$work" || exit 99
unset GROFF_BIN_PATH

echo "testing that groff finds itself in the first matching element" >&2
output=$(echo | PATH="$work/*/bin" GROFF_FONT_PATH="$fontpath" \
    groff -Z -Tascii)
echo "$output"
test "$output" = "$work/b/bin:$work/*/bin"

# vim:set autoindent expandtab shiftwidth=4 tabstop=4 textwidth=72:
