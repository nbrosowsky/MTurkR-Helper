run_batch <- function(project.info = NULL){
  
                if(is.null(project.info)){
                  message: "no project info provided"
                  return
                }
  
                timeCounter = 0
                repeat {
                  g <- GetHIT(project.info$hits[[length(project.info$hits)]]$HITId, response.group = "HITAssignmentSummary",verbose = FALSE)$HITs$NumberOfAssignmentsPending
                  
                  
                  # check if all assignmentsPerBatch have been completed
                  if (as.numeric(g) == 0) {
                    # if yes, retrieve submitted assignments
                    w <- length(project.info$data) + 1
                    project.info$data[[w]] <- GetAssignments(hit = project.info$hits[[length(project.info$hits)]]$HITId)
                    
                    # assign blocking qualification to workers who completed previous HIT
                    AssignQualification(project.info$qualification$QualificationTypeId, project.info$data[[w]]$WorkerId, verbose = FALSE)
                    
                    # increment number of completed assignments
                    project.info$batch.completed <- project.info$batch.completed + nrow(project.info$data[[w]])
                    
                    # display total assignments completed thus far
                    message(paste("Total assignments completed: ", project.info$batch.completed, "\n", sep=""))
          
                    # reset counter
                    timeCounter = 0
                    
                    # check if enough assignments have been completed
                    if(project.info$batch.completed >= project.info$batch.total) {
                      #if completed collapse lists of data into single dataframe & quit
                      
                      project.info$data <- do.call("rbind", project.info$data)
                      
                      break
                      
                      } else {
                
                          # sets number of assignments to 9 or less if required
                          newAssignments = 9
                          
                          if(project.info$batch.total - project.info$bath.completed < 9){ 
                            newAssignments = project.info$batch.total-project.info$batch.completed
                          }
                          
                          # create next hit
                          myHit <- CreateHIT(
                            project.info$hittype$HITTypeId, 
                            question    = project.info$external.question$string, 
                            expiration  = seconds(days = 1), 
                            assignments = newAssignments # IMPORTANT THAT THIS IS <= 9
                          )
                          
                          link <- paste("https://workers.mturk.com/mturk/preview?groupId=", myHit$HITTypeId, sep="") 
                          myHit$link<-link
                          
                          project.info$hits[[length(project.info$hits) + 1]]<-myHit
                          save(project.info,file="mTurkInfo.Rda")
                          
                          # wait some time and check again
                          Sys.sleep(180)
                    }
                    
          
                  } else {
                    # wait some time and check again
                    message(paste("checking... still pending: ",g, sep = " "))
                    timeCounter = timeCounter + 0.5
                    message(paste(timeCounter, "minutes", sep=" "))
                    Sys.sleep(30) # TIME (IN SECONDS) TO WAIT BETWEEN CHECKING FOR ASSIGNMENTS
                  }
                }
}
