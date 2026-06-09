" ~/.vim/plugin/ssheader.vim
" Plugin para criar e actualizar o cabeçalho Ser Superior (SSHeader)

if exists('g:loaded_ssheader')
    finish
endif
let g:loaded_ssheader = 1

" Detecta automaticamente os delimitadores de comentários conforme o filetype
function! s:get_delimiters()
    let l:ft = &filetype
    if l:ft == 'makefile' || l:ft == 'python' || l:ft == 'sh' || l:ft == 'fish'
        return ['# ', ' #']
    elseif l:ft == 'c' || l:ft == 'cpp' || l:ft == 'ss' || l:ft == 'javascript'
        return ['/* ', ' */']
    else
        return ['# ', ' #'] " Salvaguarda padrão
    endif
endfunction

" Função auxiliar para formatar e truncar o nome do ficheiro a um tamanho fixo (42 caracteres)
function! s:format_filename(filename, max_length)
    let l:fn = a:filename
    if strlen(l:fn) > a:max_length
        let l:fn = strpart(l:fn, 0, a:max_length - 3) . "..."
    endif
    let l:pad_len = a:max_length - strlen(l:fn)
    return l:fn . repeat(' ', l:pad_len)
endfunction

" Função auxiliar para formatar e alinhar a linha estritamente a 80 colunas
function! s:pad_line(left_text, logo, target_right_width, lc, rc)
    let l:spaces_after_logo = a:target_right_width - strlen(a:logo) - strlen(a:rc)
    if l:spaces_after_logo < 0
        let l:spaces_after_logo = 0
    endif
    let l:right_part = a:logo . repeat(' ', l:spaces_after_logo) . a:rc
    
    let l:left_space_available = 80 - strlen(l:right_part) - strlen(a:lc)
    let l:left_text = a:left_text
    if strlen(l:left_text) > l:left_space_available
        let l:left_text = strpart(l:left_text, 0, l:left_space_available)
    endif
    let l:pad_len = l:left_space_available - strlen(l:left_text)
    
    return a:lc . l:left_text . repeat(' ', l:pad_len) . l:right_part
endfunction

" Função principal: Insere um novo cabeçalho ou actualiza o timestamp existente
function! SSHeaderOrUpdate()
    let l:delims = s:get_delimiters()
    let l:lc = l:delims[0]
    let l:rc = l:delims[1]
    
    let l:user = "Ser Superior"
    let l:email = "<marcioeduine@gmail.com>"
    
    " O teu logótipo ASCII exclusivo
    let l:logo = [
    \ "::::::::   ::::::::",
    \ ":+:    :+: :+:    :+:",
    \ "+:+        +:+",
    \ "+#++:++#++ +#++:++#++",
    \ "+#+        +#+",
    \ "#+#    #+# #+#    #+#",
    \ "########   ########"
    \ ]
    
    let l:filename = expand("%:t")
    if l:filename == ""
        let l:filename = "stdin"
    endif
    
    let l:current_time = strftime("%Y/%m/%d %H:%M:%S")
    
    " Verifica se o cabeçalho já existe nas primeiras 12 linhas (lógica simplificada do Lua)
    let l:has_header = 0
    let l:max_check = line('$') < 12 ? line('$') : 12
    for l:i in range(1, l:max_check)
        if getline(l:i) =~ 'Created:'
            let l:has_header = 1
            break
        endif
    endfor
    
    if l:has_header
        " Actualiza apenas a linha correspondente ao timestamp de modificação
        for l:i in range(1, l:max_check)
            if getline(l:i) =~ 'Updated:'
                let l:left_text = "   Updated: " . l:current_time . " by " . l:user
                let l:updated_line = s:pad_line(l:left_text, l:logo[6], 29, l:lc, l:rc)
                call setline(l:i, l:updated_line)
                echo "[SSHeader] Cabeçalho actualizado com sucesso!"
                return
            endif
        endfor
    else
        " Constrói e injecta o novo cabeçalho de 11 linhas do zero
        let l:internal_asterisks = 80 - strlen(l:lc) - strlen(l:rc)
        let l:border = l:lc . repeat('*', l:internal_asterisks) . l:rc
        
        " Aplica a formatação rígida de 42 colunas para o nome do ficheiro
        let l:filename_formatted = s:format_filename(l:filename, 42)
        
        let l:header = []
        call add(l:header, l:border)
        call add(l:header, s:pad_line("", "", 0, l:lc, l:rc))
        call add(l:header, s:pad_line("", l:logo[0], 23, l:lc, l:rc))
        call add(l:header, s:pad_line("   " . l:filename_formatted, l:logo[1], 25, l:lc, l:rc))
        call add(l:header, s:pad_line("", l:logo[2], 26, l:lc, l:rc))
        call add(l:header, s:pad_line("   By: " . l:user . " " . l:email, l:logo[3], 27, l:lc, l:rc))
        call add(l:header, s:pad_line("", l:logo[4], 21, l:lc, l:rc))
        call add(l:header, s:pad_line("   Created: " . l:current_time . " by " . l:user, l:logo[5], 29, l:lc, l:rc))
        call add(l:header, s:pad_line("   Updated: " . l:current_time . " by " . l:user, l:logo[6], 29, l:lc, l:rc))
        call add(l:header, s:pad_line("", "", 0, l:lc, l:rc))
        call add(l:header, l:border)
        
        call append(0, l:header)
        echo "[SSHeader] Novo cabeçalho introduzido!"
    endif
endfunction

" Criação do comando ex para execução manual
command! SSHeader call SSHeaderOrUpdate()

" Mapeamento da tua tecla personalizada (<F4> no modo Normal)
nnoremap <silent> <F4> :SSHeader<CR>

" Função para atualizar o cabeçalho automaticamente apenas ao salvar se houver alterações
function! s:update_on_save()
    if &modified
        let l:has_header = 0
        let l:max_check = line('$') < 12 ? line('$') : 12
        for l:i in range(1, l:max_check)
            if getline(l:i) =~ 'Created:'
                let l:has_header = 1
                break
            endif
        endfor
        if l:has_header
            call SSHeaderOrUpdate()
        endif
    endif
endfunction

augroup SSHeaderAutoUpdate
    autocmd!
    autocmd BufWritePre * call <SID>update_on_save()
augroup END

" Função para desativar o autocomando do stdheader global da escola
function! s:disable_global_stdheader()
    try
        autocmd! stdheader BufWritePre *
    catch
    endtry
    try
        autocmd! BufWritePre *
    catch
    endtry
endfunction

" Registra a desativação para correr logo após a inicialização do Vim
autocmd VimEnter * call <SID>disable_global_stdheader()
