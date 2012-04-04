" =============================================================================
" Configuration
" =============================================================================

function s:SourceDirs()
  if exists("b:alternate_source_dirs")
    return b:alternate_source_dirs
  endif
  return '*'
endfunction

function s:TestDirs()
  if exists("b:alternate_test_dirs")
    return b:alternate_test_dirs
  endif
  return '*'
endfunction

function s:TestToken()
  if exists("b:alternate_test_token")
    return b:alternate_test_token
  endif
  return '_test'
endfunction

function s:TestTokenLocation()
  if exists("b:alternate_test_token_location")
    return b:alternate_test_token_location
  endif
  return '$'
endfunction

" =============================================================================
" Public Interface
" =============================================================================

function alternate#Alternate()
  let alternate = alternate#FindAlternate()
  if len(alternate) > 1
    execute 'edit ' . alternate
  else
    echo 'No alternate file could be found.'
  endif
endfunction

function alternate#FindAlternate()
  let file_path = expand('%')
  return s:ChooseAlternateFile(file_path, s:FindAlternateFiles())
endfunction

function alternate#FindTest()
  let file_path = expand('%')
  let file_name = expand('%:t:r:r')
  if s:IsTest(file_name)
    return file_path
  endif
  let file_extension = expand('%:e:e')
  return s:ChooseAlternateFile(file_path, s:FindTestFiles(file_name, file_extension))
endfunction

" =============================================================================
" Private Interface
" =============================================================================

function s:ChooseAlternateFile(current_path, alternative_paths)
  " If there are multiple matches, look for one with the same parent directory.
  if len(a:alternative_paths) > 1
    for alternate_path in a:alternative_paths
      if s:ParentDirectoryName(a:current_path) == s:ParentDirectoryName(alternate_path)
        return alternate_path
      endif
    endfor
  endif

  " Otherise, always pick the first match.
  return get(a:alternative_paths, 0)
endfunction

function s:FindAlternateFiles()
  let file_name      = expand('%:t:r:r')
  let file_extension = expand('%:e:e')
  if s:IsTest(file_name)
    return s:FindSourceFiles(file_name, file_extension)
  else
    return s:FindTestFiles(file_name, file_extension)
  endif
endfunction

function s:IsTest(file_name)
  return match(a:file_name, s:FindTestToken()) != -1
endfunction

function s:FindSourceFiles(test_file_name, extension)
  let file_name = substitute(a:test_file_name, s:FindTestToken(), '', '')
  return s:FindFiles(s:SourceDirs(), file_name, a:extension)
endfunction

function s:FindTestFiles(source_file_name, extension)
  let file_name = substitute(a:source_file_name, s:TestTokenLocation(), s:TestToken(), '')
  return s:FindFiles(s:TestDirs(), file_name, a:extension)
endfunction

function s:FindFiles(search_dirs, file_name, file_extension)
  return split(globpath(a:search_dirs, '**/' . a:file_name . '.' .a:file_extension), '\n')
endfunction

function s:FindTestToken()
  return substitute(s:TestToken(), s:TestTokenLocation(), s:TestTokenLocation(), '')
endfunction

function s:ParentDirectoryName(path)
  return fnamemodify(a:path, ':h:t')
endfunction

