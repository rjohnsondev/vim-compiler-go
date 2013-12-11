if !empty($GOROOT) && !exists('g:golang_goroot')
    let g:golang_goroot = $GOROOT
endif
if !exists('g:golang_goroot')
    let g:golang_goroot = '/usr/bin'
    echoerr 'Please set $GOROOT or g:golang_goroot'
endif
