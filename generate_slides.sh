SOURCE_FORMAT="markdown_strict\
    +pipe_tables\
    +backtick_code_blocks\
    +auto_identifiers\
    +strikeout\
    +yaml_metadata_block\
    +implicit_figures\
    +all_symbols_escapable\
    +link_attributes\
    +smart\
    +fenced_divs"

pandoc -s \
    --verbose \
    --output=build/verilog_crashcourse.pdf \
    --slide-level 2 \
    --shift-heading-level=-1 \
    --listings \
    --toc \
    --columns=50 \
    -f "$SOURCE_FORMAT" \
    --template pandoc/templates/default_mod.latex \
    -t beamer \
    --from=markdown+rebase_relative_paths \
    verilog_crashcourse.md 

