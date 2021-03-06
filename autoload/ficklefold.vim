function! ficklefold#init_options()
    if !exists("b:fold_toggle_options")
        " By default, use the main two. I rarely use manual and diff is just
        " for diffing. Only use expr if it has an expression setup.
        let b:fold_toggle_options = ["indent", "marker"]
        if len(&l:foldexpr) > 1
            let b:fold_toggle_options += ["expr"]
        endif
        " Only use syntax if already enabled. See also
        " david#indent#try_use_syntax_folds() for a good way to detect if it's
        " usable.
        if &l:foldmethod == "syntax"
            " Syntax at the start.
            let b:fold_toggle_options = ["syntax"] + b:fold_toggle_options
        endif
    endif
endf

" Easily switch between different fold methods
function! ficklefold#ToggleFold()
    call ficklefold#init_options()

    " Find the current setting in the list
    let i = match(b:fold_toggle_options, &foldmethod)

    " FastFold will modify fdm as soon as it's set to 'syntax' (see
    " OptionSet)! So if we couldn't find the fdm and it's 'manual' (fastfold
    " mode), it's effectively syntax.
    if i < 0 && &foldmethod == "manual"
        let i = match(b:fold_toggle_options, 'syntax')
    endif

    " Advance to the next setting
    let i = (i + 1) % len(b:fold_toggle_options)
    let &l:foldmethod = b:fold_toggle_options[i]

    echo 'foldmethod is now ' . &l:foldmethod
endfunction


" Fold away every line that doesn't match the query.
"
" Works kind of like :print in :g/re/p, but within the buffer. Pass empty
" query to clear created folds.
"
" Will destroy manual folds.
"
" Source: https://www.reddit.com/r/vim/comments/3ens31/gp_with_syntax_highlighting/ctgotf3
function! ficklefold#FoldAllButMatches(query)
    " Clear all manual folds.
    silent! g/^/norm! zD

    if len(a:query) > 0
        let b:ficklefold_cached_foldmethod = &foldmethod
        let b:ficklefold_cached_foldminlines = &foldminlines

        set foldmethod=manual foldminlines=0
        exec 'v/'. a:query .'/fold'

    elseif exists('b:ficklefold_cached_foldmethod')
        let &foldmethod = b:ficklefold_cached_foldmethod
        let &foldminlines = b:ficklefold_cached_foldminlines
        unlet b:ficklefold_cached_foldmethod
        unlet b:ficklefold_cached_foldminlines

    else
        echoerr "FoldAllButMatches requires an argument to search for."
    endif
endf


" Fold paragraphs of prose.
function! ficklefold#FoldParagraphs()
    setlocal foldmethod=expr
    setlocal fde=getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1
    if exists("b:fold_toggle_options")
        let b:fold_toggle_options += ["expr"]
    endif
endfunction

