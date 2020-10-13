
################################################
### Running scripts in parallel for Ecologists 
## Gabriel Muñoz 
## Community Ecology and Biogeography Lab. 
## Concordia University 
################################################

## Background 

## Quantitiative ecological analisis often require analysis that are computationally expensive. 
## Many insitiutions provide access to remote servers (computational clusters) to researchers. 
## A computer cluster can significanly speed up time consuming analysis, reducing in x-folds the time spent on iterative type of analysis such as null-models
## The code however, has to be written in a particular form and be computationally effective in order to make best use of all the computational power of a cluster.
## With this short tutorial, I hope to provide a basis that can help adapting your code to be run in parallel inside a computer cluster. 


## What is a computer cluster? 

# Shortly, a computer cluster is a network of computer processors. Individually, each processor may be even slower than your average laptop. However, all  operating in ensemble creates a great computational capacity.
# The principal advantage of a computer cluster is the ability to process iterative analyisis independently, thereby reducing computational time proportionally to the number of clusters (and the effectivness of your code)
# Therefore, the best way to submit code to a computer cluster is making sure that your code is composed by functions that each do a single process and can be called iterativelly. 
# Your final output should be the aggregated result, or a summary statistic of the individual processes. 


## Here a minimalistic flow-diagram how a computer cluster operates 
## we can subdivide clusters into masters and slaves cores. The human operator communicates with the master core, and provides the instructions (code) with the tasks (programs written in functions) that this master core will distribute to the slave cores 
## Then, we must calculate the number of cores needed as the (n+1) accounting for the master core, which will not perform any calculations. Only send and compile information processed by the slaved cores.  

# You ---> code ----> Cluster  (1 master core) ----> n SlaveCores (processing) ---> Master core (compiling) ---> Output--->You


## Practical example 


## lets randomly create a pool to sample
PoolA <- round(rnorm(1000,2, 0.1 ),2)
PoolB <- round(rnorm(1000,1.4, 0.3 ),2)

hist(PoolB, xlim = c(0,3), ylim = c(0,400))
hist(PoolA,add = T, col = "red")

# Let's say we want to create a null model to estimate if stochastic processes drive true differences between the ranges among samples

sampleA <- sample(PoolA, 100)
sampleB <- sample(PoolB, 100)

# observed differences between sample ranges
obsRangeDiff <- abs(diff(range(sampleA))-diff(range(sampleB)))

## Lets create a distribution of expected range difference values by iterating the sample from the pool to later compute Z-scores
## To create the distribution we can replicate the sampling process 100 times.
# let's create a function that does just that. 

replicatorFunct <-function(PoolA, PoolB, size, nRep){
  myExpectedDis <- replicate(nRep,
                             abs(
                               diff(range(sample(PoolA, size)))-diff(range(sample(PoolB, size)))
                               ))
}

## Let's estimate how much time this will take on a single processor 

start <- Sys.time()
OneCore <- replicatorFunct(PoolA, PoolB, size = 100,nRep =  1000)
timeUsed <- start-Sys.time()

# Time spent in this processing task. (this is not a heavy task, so operational times are fast)
print(abs(timeUsed))

# Let's see how much we can reduce computational time if this code was run in a cluster. 
# We will use the library snowfall -- see: ?snowfall for more info
library(snowfall)

## The first step is to open the cluster and set the number of clusters (Parallel task can be run in laptops with multiple core processors, the limitation there is the number of processors in your computer, example my Mac2013 has 4 processors)
## cpu's is the number of cores to initialize the cluster
snowfall::sfInit(parallel = T, cpus = 21, type = "SOCK")
# now the cluster is initiated we need to send all the necessary info for the program to run in parallel. Think about the cluster as a separate computer controlled by yours. 
# Let's prepare the script with the functions above in a new file called Functions.R (in the same working directory)

# let's send that file with the functions to the cluster with
snowfall::sfSource("Functions.R")
# if you need to send data, you can do it with 
# snowfall::sfExport()

start1 <- Sys.time()
ManyCore <- replicatorFunct(PoolA, PoolB, size = 100,nRep =  1000)
timeUsed2 <- start1-Sys.time()

# to stop the cluster
snowfall::sfStop()

# let's check the time gained (providing that you highlighted all 3 lines of code and run it at once to avoid click delays)
timeUsed2 - timeUsed

## Be aware that all the lapply familiy of functions have its corresponding in snowfall
# e.g. 


NoClust <- sapply(1:100, function(x) mean(sample(x)))

snowfall::sfInit(parallel = T, cpus = 21, type = "SOCK")
WithClust <- sfSapply(1:100, function(x) mean(sample(x)))
snowfall::sfStop()



### Questions?
# gabriel.munoz@concordia.ca
