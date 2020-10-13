## Functions 

replicatorFunct <-function(PoolA, PoolB, size, nRep){
  myExpectedDis <- replicate(nRep,
                             abs(
                               diff(range(sample(PoolA, size)))-diff(range(sample(PoolB, size)))
                             ))
}


