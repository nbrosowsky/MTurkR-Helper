init_mturkR <- function(){
  Sys.setenv(
    AWS_ACCESS_KEY_ID = 'YOUR ACCESS KEY ID',
    AWS_SECRET_ACCESS_KEY = 'YOUR SECRET ACCESS KEY'
  )
  
  ### IMPORTANT! SET SANDBOX TRUE/FALSE ####
  ### can always change after 
  options('MTurkR.sandbox' = FALSE) 
  options("MTurkR.verbose" = TRUE)
}
