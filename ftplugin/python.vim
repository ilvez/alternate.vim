let b:alternate_test_token          = "test_"
let b:alternate_test_token_location = "^"

command! -buffer -nargs=0 Alternate    call alternate#Alternate()
command! -buffer -nargs=1 RunTestUsing call alternate#RunTestUsing(<args>)
