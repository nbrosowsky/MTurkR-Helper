## creates single HIT with qualification for single worker
comp_HIT <- function(worker = NULL,
                    reward = NULL,
                    contact = TRUE,
                    project = NULL)
  {
        
        #Catch missing info
        if(is.null(worker)){
          message:"No worker ID given"
          return()
        } 
        
        if(is.null(reward)){
          message:"No reward amount given"
          return()
        }
        
        #Create qualification to only allow worker to complete HIT
        tempQual <- CreateQualificationType(paste('Qualification for Worker', worker),
                                            paste('Temporary Qualification for', worker), 
                                            'Active')
        #Assign qualification to worker
        AssignQualification(tempQual$QualificationTypeId, worker, value="100")
        
        #Create qualification requirement for HIT
        tempQR <- GenerateQualificationRequirement(tempQual$QualificationTypeId, "=", "100", preview = TRUE)
        
        #Create HIT form
        questionForm <- paste(
                        "<QuestionForm xmlns=\'http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd\'>",  
                            "<Overview>",    
                              "<Title>Please Click \"Yes\" Below</Title>",    
                              "<Text>Sorry you had problems with the HIT. Please click \"yes\" below to be paid.</Text>",  
                            "</Overview>",  
                            "<Question>",    
                              "<QuestionIdentifier>question1</QuestionIdentifier>",    
                              "<IsRequired>true</IsRequired>",    
                              "<QuestionContent>",     
                                "<Text>Just click \"Yes\"</Text>",    
                              "</QuestionContent>",    
                              "<AnswerSpecification>",      
                                "<SelectionAnswer>",        
                                "<StyleSuggestion>radiobutton</StyleSuggestion>",       
                                "<Selections>",          
                                "<Selection>",            
                                "<SelectionIdentifier>1</SelectionIdentifier>",            
                                "<Text>Yes</Text>",          
                                "</Selection></Selections>",     
                                "</SelectionAnswer>",    
                              "</AnswerSpecification>",  
                            "</Question>",
                        "</QuestionForm>",
                        sep = " ")
        
        #Create hit
        tempHIT <- CreateHIT(
                      title       = paste("Temporary HIT for", worker),
                      description = paste("Temporary HIT for", worker),
                      reward      = reward,
                      keywords    = "technical error",
                      duration    = seconds(hours=1),
                      
                      # attach the new QualificationRequirement data structure:
                      qual.req    = tempQR, 
                      expiration  = seconds(days=3),
                      
                      # one second delay in autoapproval:
                      auto.approval.delay = '1', 
                      
                      # a question string or hitlayoutid must be specified:
                      # this example uses the simple `questionform.txt` example (from below)
                      question = questionForm
                    )
        
        #Contact info
        defaultSubject <- 'Complete HIT to get paid'
        defaultMSG     <- "I've created a HIT for you to be paid. Just search for your worker ID.\n
                          All you have to do is select Yes and submit. You will be paid automatically.\n
                          Sorry for the inconvenience."
        
        #Contact worker
        if(contact == TRUE){
          ContactWorker(workers = worker, 
                        subjects = defaultSubject,
                        msgs = defaultMSG 
          )
          
        }
        
        #Log hit link
        tempLink = paste("https://worker.mturk.com/mturk/preview?groupId=", tempHIT$HITTypeId, sep="")
        
        #Compile info into list
        all <- list()
        
        all$workerId                  <- worker
        all$qualification             <- tempQual
        all$qualification.requirement <- tempQR
        all$hit                       <- tempHIT
        all$link                      <- tempLink
    
    # if project variable is provided, add comp to project.info$comps
    if(!is.null(project)){
       project.info$comps[[length(project.info$comps + 1)]] <- all
       save(project.info,file="mTurkInfo.Rda")
    } 
        
    #Return all info
    return(all)
  
  }