rm(list=ls())
library(cvxclustr)
library(scvxclustr)
library(gglasso)

###Generate a simple data matrix used for clustering, of which the rows are samples and the ###columns are variables. Here we produce a matrix consisted of 80 observations and 100 ###variables(the first 20 are informative variables). There exist 2 classes in this data.

class1 <- sample(1:80, 40)
class2 <- setdiff(1:80, train)
r1 <- rep(0, 80)
r1[class1] <- 1

sample1_matrix <- matrix(0, nrow = 80, ncol = 20)
for (i in which(r1 == 0)) {
  sample1_matrix[i, ] <- rnorm(20, mean = 1, sd = 0.5)
}

for (i in which(r1 == 1)) {
  sample1_matrix[i, ] <- rnorm(20, mean = -1, sd = 0.5)
}

sample2_matrix <- matrix(rnorm(14400, mean = 4, sd = 1), nrow = 80, ncol = 80)
sample_matrix <- cbind(sample1_matrix, sample2_matrix)
sample_scale <- scale(sample_matrix, scale = F)

n <- nrow(sample_matrix)
p <- ncol(sample_matrix)

###construct sparse weights at first and then use it to take convex clustering by AMA ###algorithm from package "cvxclustr"

weight <- kernel_weights(t(sample_matrix), 0.5)
weight <- knn_weights(weight, 5, n)
weight <- weight/(sqrt(p) * sum(weight))

cvx_result <- cvxclust(X = t(sample_matrix), w = weight, gamma = 1e14, method = "ama", nu = 0.01)

###construct adjacency matrix to get final clustering results. Here we can see the clustering ###results by object "cluster", and we find that most observations are classified into 2 classes.

A <- create_adjacency(cvx_result$V[[1]], weight, n, method = "ama")
cluster <- find_clusters(A)
cluster

###Construct sparse weights at first and then use it to take convex clustering by AMA ###algorithm from package "cvxclustr". In this step we get the sparse weights for gamma_1 ###and the weights for gamma_2

weight <- kernel_weights(t(sample_scale), 0.5)
weight <- knn_weights(weight, 5, n)
weight <- weight/(sqrt(p) * sum(weight))

Gamma1 <- 1e15
Gamma2 <- 10

cvxresult <- cvxclust(t(sample_scale), nu = 0.01, weight, gamma = Gamma1, method = "ama", accelerate = F)$U[[1]]
cvxresult <- t(cvxresult)

mu <- vector()
for (j in 1:p) {
  mu[j] <- 1/(sqrt(sum(cvxresult[, j]^2)) + 1e-6)
}

Gamma2_weight <- mu/(sqrt(n)*sum(mu))

nu <- AMA_step_size(weight, n)/2

###In this step, we get the sparse convex clustering result and put it into the same function ###"create_adjacency" to get the adjacency matrix so that we can get final clustering classes.

system.time(tt <- scvxclust(X = sample_scale, weight, nu = nu, Gamma1 = Gamma1, Gamma2 = Gamma2, Gamma2_weight = Gamma2_weight, method = "ama", max_iter = 1e4, tol_abs = 1e-5))

A <- create_adjacency(tt$V[[1]], weight, 80, method = "ama")
cluster <- find_clusters(A)
cluster

tt$V[[1]]

###Thus the main problem is that we use S-AMA to get a clustering result. But no matter how ###large the value of gamma_1 is set, the final object "cluster" may reflect that every one ###sample belongs to one class, while the AMA result may not fall into such situation.
###I find the difference may comes from whether we truncate matrix V, because AMA forms a ###truncated V matrix, while S-AMA not do this.