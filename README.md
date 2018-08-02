Note: this is a work in progress…

I’ve created a number of helper/wrapper functions to streamline my
workflow using mTurkR and thought I would share here in case they are
helpful to anyone else. All the functions can be easily edited for your
own needs.

The main purpose for creating these functions was that I
found it difficult to keep all the information related to an experiment
organized while I was using the batch loop.

The main idea is that a “project.info” list object is created that
stores all the relevant Amazon Mechanical Turk information related to
the project (e.g., Hits, qualifications, number of hits completed, etc.)
and saves this list to “mTurkInfo.Rda”. Whenever I do something like run
the batch loop or compensate a worker, it updates this list and resaves
the file.

The real benefit is that I have all the information related to a single
experiment saved to a single file where I can easily reload it. This
also made it substantially easier to stop the batch loop and restart it
at another time (simply by loading the project file and running the
batch loop again)

What follows would be my basic workflow:

Initiate MTurkR with MTurk credentials
--------------------------------------

This function simply initiates mTurkR with my Amazon credentials (you’ll
have to add your own to the function). By default it sets the sandbox
option to FALSE, but this can be changed anytime.

``` r
library(MTurkR)

source(file="init.R")
init_mturkR()
```

Create project and first HIT
----------------------------

The create\_project function creates the project.info list container,
automatically saves this list to mTurkInfo.Rda, and runs the first HIT
with 9 assignments

This function is clunky right now and has a bunch of default behaviors
including setting qualifications (also missing fallbacks). You would want to double-check this
function to ensure that it is creating the HIT the way you’d like.

exclude.workers should be a path to an Rda file containing worker Ids
you wish to exclude from participating. For example, if this experiment
is too similar to another, then you can point to list containing prior
workers. It only uses this list once when the project is created.

``` r
  source(file="creat_project.R")

  # creates project container containing all relevant info
  # creates first hit for batch
  project.info <- create_project(
                                  title = "This is a title for your HIT",
                                  description = "This is the description",
                                  reward = "6.00",
                                  duration = 1800,
                                  auto.approve.delay = seconds(hours = 1),
                                  keywords = "psychology, experiment, typing, opinion, writing",
                                  expURL = "https://nbrosowsky.github.io/ExpDemos/FaceInversion/task.html",
                                  HITexpiration = seconds(days = 1),
                                  batch.total = 300,
                                  exclude.workers = "mTurkR/previousComps.Rda"
                                )
```

Run Batch Loop
--------------

This function runs the batch loop as outlined by the MTurkR docs. After
each successful batch the project.info list is updated and all info/data
is stored and re-saved to mTurkInfo.Rda

``` r
  source(file="run_batch.R")

  # will run batch loop until completed
  run_batch(project.info = project.info)
```

Compensate worker with new HIT
------------------------------

This function creates a new hit with a special qualification for a
single worker. By default it tries to contact the worker to let them
know you’ve created this compensation hit (though you can’t contact
workers who have never worked for you before).

-   It will add the comp information to the project.info and resave
    mTurkR.Rda
-   It will also create a link that you can copy/paste to send to the
    worker if need be
-   Will return a list of comp info

``` r
    source(file="compHit.R")

    # comp hit
    newComp <- compHit(worker  = "123456789",
                      reward  = "5.00",
                      contact = TRUE,
                      project = project.info)
```

Misc Get functions
------------------

These are just wrappers to help me retrieve various info

``` r
  source(file="get.R")

  # retrieves the last HIT run by date
  get_LastHit()
  
  # retrieve the number of pending by hit id
  get_HitPending(hit = [hit id])
  
  # retrieve the number of pending assignments for a hit type (sums across hits / returns a single number)
  get_AllPending(hit.type = [hit type id])
  
  #returns number of assignments completed for HIT type  (sums across hits / returns a single number) 
  get_AllCompleted(hit.type = [hit type id])
```
