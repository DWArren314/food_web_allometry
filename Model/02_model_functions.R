library(dplyr)
library(gtools)

## parameters

attack_r <- function(a0, br, e, m) {
  a0*(m^br)*(3.3/(m))*exp(e*(3.3/m))
}

handling_r <- function(h0,al, m){
  h0*(m^al)
}

carrying <- function(k0, k, m){
  K <- k0* m ^ k
}

carrying_gausian <- function(Km, sig_K, um, m){
  K <- Km*exp(-((m - um)^2)/(2*sig_K^2)) 
}

growth_rate <- function(rmax, r, m){
  growthrate <-  rmax * m ^ r
}

### estimate parameters given m

parameters_given_bm <- function(m){
  a <- attack_r(a0 = 0.0005, br = 1.30000000 ,e = 0.07172922  , m)
  h <- handling_r(h0 = 5, al = 2.41854333, m)
  gr <- growth_rate(rmax = 0.05, r = -0.20, m)
  K <- carrying(k0 = 6, k = -1, m)
  return(list(a, h, K, gr))
}

interaction_st <- function(m, min.value, max.value, Be = 0.5){
  is <- (1/(1 + ((m[1] - m[2] + Be)^2)/(2*(0.025^2))))*(1 + ((Be^2)/(2*(0.025^2))))
  
  return(is)
}

interaction_name <- function(preys){
  paste0('is', preys[1],preys[2])
}

interaction_all <- function(preybm_vector, min.value, max.value, Be){
  
  total_prey <- length(preybm_vector)
  
  combs_all <- permutations(n = total_prey, v = 1:total_prey, r = 2)
  
  combs_bm <- matrix(preybm_vector[combs_all], ncol = 2)
  
  values_is <- apply(combs_bm, 1, interaction_st, min.value = 0.02, max.value = 0.5, Be)  
  
  names_is <- apply(combs_all, 1, interaction_name)  
  
  names(values_is) = names_is
  
  return(values_is)
}

prey_names <- function(total_prey){
  name_list <- list(c("R1", "P"), c("R1", "R2", "P"), c("R1", "R2", "R3", "P"),
                    c("R1", "R2", "R3", "R4", "P"), c("R1", "R2", "R3", "R4", "R5","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","P"), c("R1", "R2", "R3", "R4", "R5", "R6","R7","P"), 
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","P"), c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","R17","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","R17","R18","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","R17","R18","R19","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","R17","R18","R19","R20","P"),
                    c("R1", "R2", "R3", "R4", "R5", "R6","R7","R8","R9", "R10","R11","R12","R13","R14","R15","R16","R17","R18","R19","R20","R21","P"))
  name_selected <- name_list[[total_prey]]
  return(name_selected)
}



parameters <- function(preybm_vector, Be){
  all_params <- parameters_given_bm(preybm_vector)
  
  total_prey <- length(preybm_vector)
  
  rnames <- paste0('r', 1:total_prey)
  r <- all_params[[4]]
  names(r) <- rnames
  
  knames <- paste0('K', 1:total_prey)
  K <- all_params[[3]]
  names(K) <- knames
  
  anames <- paste0('a', 1:total_prey)
  a <- all_params[[1]]
  names(a) <- anames
  
  hnames <- paste0('h', 1:total_prey)
  h <- all_params[[2]]
  names(h) <- hnames
  
  if(total_prey == 1){
    is_all <- 0
  }else{
    is_all <- interaction_all(preybm_vector, min.value, max.value, Be = Be)
  }
  
  parameters <- c(r, K, a, h, is_all,
                  B = 0.2, C = 0.4)
  
  return(parameters)
}




## model choice depending on the number of prey used

prey_number_stoch <- function()
  list(prey_advance1, prey_advance2, prey_advance3more)

use_prey_number_stoch <- function(ll){
  ll <- ifelse(ll > 3, 3, ll)
  unlist(prey_number_stoch()[[ll]])
}


prey_advance1 <- function(pret, rv, kv, av, hv, Pt, B, C, total_prey, is){
  pret2 <- pret + rpois(1, rv*pret)*(1 - (pret/kv)) - av*pret*Pt/(1 + sum(av*hv*pret))
  Pt2 <- Pt + rpois(1,Pt*B*sum(av*pret)/(1 + sum(av*hv*pret)))- C*Pt
  nt2 <- c(pret2, Pt2)
  return(nt2)
}


prey_advance2 <- function(pret, rv, kv, av, hv, Pt, B, C, total_prey, is){
  pret2 <- pret + sapply(1:total_prey, FUN = function(x){rpois(1, rv[x]*pret[x])})*(1 - ((pret + sapply(1:total_prey, FUN = function(x){sum(is[x]*pret[-x])}))/kv)) -
    av*pret*Pt/(1 + sum(av*hv*pret))  
  
  Pt2 <- Pt + rpois(1,Pt*B*sum(av*pret)/(1 + sum(av*hv*pret)))- C*Pt
  nt2 <- c(pret2, Pt2)
  return(nt2)
}


prey_advance3more <- function(pret, rv, kv, av, hv, Pt, B, C, total_prey, is){
  pret2 <- pret + sapply(1:total_prey, FUN = function(x){rpois(1, rv[x]*pret[x])})*(1 - ((pret + sapply(1:total_prey, FUN = function(x){sum(is[((total_prey-1)*x-(total_prey-2)):((total_prey-1)*x)]*pret[-x])}))/kv)) -
    av*pret*Pt/(1 + sum(av*hv*pret))
  
  Pt2 <- Pt + rpois(1,Pt*B*sum(av*pret)/(1 + sum(av*hv*pret)))- C*Pt
  nt2 <- c(pret2, Pt2)
  return(nt2)
}


#### Function that runs the stochastic model

run_stochastic_model <- function(preybm_vector, generations, Be){

  total_prey <- length(preybm_vector)
  
  rv <- parameters_given_bm(preybm_vector)[[4]]
  kv <- parameters_given_bm(preybm_vector)[[3]]
  av <- parameters_given_bm(preybm_vector)[[1]]
  hv <- parameters_given_bm(preybm_vector)[[2]]
  
  if(total_prey > 1){
    is <- interaction_all(preybm_vector, 0.02, 1, Be) 
  } else{
    is <- NULL
  }
  
  B <- 0.5
  C <- 0.05
  
  R0 <- 10
  pret <- rep(R0, total_prey)
  Pt <- 7
  
  names(pret) <- prey_names(total_prey)[1:total_prey]
  
  abundances <- data.frame(time = 0, t(pret),  P = Pt)
  
  fun_to_use <- use_prey_number_stoch(total_prey)
  
  for(g in 1:generations){
    
    nt2 <- fun_to_use(pret, rv, kv, av, hv, Pt, B, C, total_prey, is)
    
    if(any(nt2 < 0.5)){
      
      nt2[nt2 < 0.5] <- 0
    }
    pret <- nt2[1:total_prey]
    Pt <- nt2[total_prey+1]
    
    abundances <- bind_rows(abundances, data.frame(time = g, t(pret),  P = Pt))
  }
  
  return(abundances)
}

## MCMC functions to move the parameters

step_forward <- function(current.value, step.size, min.value, max.value){
  new.value <- round(rnorm(1, mean = current.value, sd = step.size), digits = 2)
  
  if(new.value >= max.value){new.value <- max.value + (max.value - new.value)}
  if(new.value <= min.value){new.value <- min.value + (min.value + abs(new.value))}
  
  return(new.value)
}


step_back <- function(current.value){
  new.value <- current.value 
  return(new.value)
}

get_new_value <- function(current.value, step.size, min.value, max.value){
  
  new_value <- step_forward(current.value, step.size, min.value, max.value)
  
  new_value
}



#### MCMC functions

species_survive <- function(output, generations){
  if(nrow(output) == generations+1){
    if(all(output[generations+1,-1] > 1)){
      TRUE
    }else{
      FALSE
    }
  }else{
    FALSE
  }
}

horizontal_diversity <- function(output, generations){
  if(nrow(output) == generations+1){
    if(sum(output[generations+1,c(-1, -ncol(output))] > 1)>=2 & output[generations+1,'P'] < 1){
      TRUE
    }else{
      FALSE
    }
  }else{
    FALSE
  }
}

vertical_diversity <- function(output, generations){
  if(nrow(output) == generations+1){
    if(output[generations+1,'P'] > 1 & any(output[generations+1,c(-1, -ncol(output))] > 1)){
      TRUE
    }else{
      FALSE
    }
  }else{
    FALSE
  }
}


run_mcmc_1 <- function(bms, params, total.min, total.max, generations, Be){
  
  new.bms <- unlist(lapply(bms, get_new_value, step.size = params$step.size, min.value = params$min.value, max.value = params$max.value))
  
  output_int <- run_stochastic_model(new.bms, generations, Be)
  
  return(list(new = new.bms, initial = bms, out = output_int))
}

type_output <- function(){
  list(species_survive, predator_maximal, horizontal_diversity, vertical_diversity)
}

use_mcmc <- function(ll){
  unlist(type_output()[[ll]])
}



run_mcmc_2 <- function(list_output_int, generations, type){
  
  output_int <- list_output_int$out
  
  bm_new <- list_output_int$new
  
  bm_init <- list_output_int$initial
  
  fun_to_use_mcmc <- use_mcmc(type)
  
  if(fun_to_use_mcmc(output_int, generations)){
    bms <- bm_new
    fail <- FALSE
  } else{
    bms <- bm_init
    fail <- TRUE
  }
  
  return(list(bms = bms, tried = bm_new, failed = fail, tail(output_int, 1)))
}




## Running for multiple species


get_final_output <- function(prey_numer, param_general, type, Be){
  
  total.min <- param_general$min.value
  
  total.max <- param_general$max.value
  
  bm_survived<- list()
  
  bms <- rep(param_general$start.value, prey_numer)
  
  simulations <- 10000
  gens <- 500
  
  for(i in 1:simulations){
    
    list_output_int <- run_mcmc_1(bms, param_general, total.min, total.max, generations = gens, Be)
    
    bms_output_run <- run_mcmc_2(list_output_int, generations = gens, type)
    
    bms <- bms_output_run$bms
    
    bm_survived[[i]] <- bms_output_run
    
  }
  
  return(bm_survived)
  
}

