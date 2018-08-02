#### CREATE MTURK PROJECT FROM SCRATCH ####
create_project <- function(
                           title = NULL,
                           description = NULL,
                           reward = NULL,
                           duration = NULL,
                           auto.approve.delay = NULL,
                           keywords = NULL,
                           expURL = NULL,
                           HITexpiration = NULL,
                           batch.total = NULL,
                           exclude.workers = NULL
                           )
{
  ## Project info container
  project.info <- list()
  
  ## Batch info
  project.info$batch.completed      <- 0           # variable to index number of completed assignments
  project.info$batch.total          <- batch.total # set total number of desired assignments
  project.info$batch.assignmentsPer <- 9           # Number of assignments per iteration / should be <= 9
  
  ## Extra storage
  project.info$data   <- list() # list to store assignments info
  project.info$hits   <- list() # list to store each hit info
  project.info$comps  <- list() # list to store any comp hit info
  
  
  
  ### create qualifications for hit
  # create QualificationType to prevent repeat participants
  # see previously created qualifications: SearchQualificationTypes()
  
  myQual <- CreateQualificationType(name=paste("Already completed similar HIT",title,sep=":"),
                                    description="Already completed similar HIT before.",
                                    status = "Active"
  )
  
  
  
  # set qualifications
  q <- paste(
    
    # percent approved
    GenerateQualificationRequirement(
      "000000000000000000L0",">","96",qual.number = 1
    ),
    
    # number of hits approved
    GenerateQualificationRequirement(
      "00000000000000000040",">","1000",qual.number = 2
    ),
    
    # location
    GenerateQualificationRequirement(
      "00000000000000000071","==","US",qual.number = 3
    ),
    
    # custom qual for non-repeats (i.e., allow all who do not hold qual)
    GenerateQualificationRequirement(
      myQual$QualificationTypeId,"DoesNotExist","",qual.number = 4
    ),
    
    sep = ""
  )
  
  myQual$string   <-  q
  project.info$qualification  <- myQual
  
  ## create a hit type
  myHitType <- RegisterHITType(
    title               = title,
    description         = description,
    reward              = reward, 
    duration            = duration, 
    auto.approval.delay = auto.approve.delay,
    keywords            = keywords,
    qual = q
  )
  
  project.info$hittype<-myHitType
  
  
  ## generate external link
  ext <- GenerateExternalQuestion(url = expURL, frame.height = "750")
  project.info$external.question <- ext
  
  
  ### add any worker on exclude list to qualification
  if(!is.null(exclude.workers)){
    load(file = exclude.workers)
    AssignQualification(project.info$qualification$QualificationTypeId, previousComps, verbose = FALSE)
  }
  
  ## create first hit
  myHit <- CreateHIT(
    myHitType$HITTypeId, 
    question    = ext$string, 
    expiration  = HITexpiration, 
    assignments = project.info$batch.assignmentsPer 
  )
  
  link <- paste("https://workers.mturk.com/mturk/preview?groupId=", myHit$HITTypeId, sep="") 
  myHit$link<-link
  
  #save hit info
  project.info$hits[[1]]<-myHit
  
  
  ### SAVE PROJECT INFO FOR BATCH ###
  save(project.info,file="mTurkInfo.Rda")
  
  return(project.info)
  
}  