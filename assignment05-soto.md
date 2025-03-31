# Part 1: Sampling Noise in a Fixed Population

## Gabriel Soto

## Objective of the section

We want to undersntad how with random sampling, can affect the result of regressions for a fixed population. This is done by having different sizes of samples and running the regression for them respectively. Our effects are that, with the change of the size of the sample, it can change the estimated effect of beta, treament, we can see hoy much it would vary (standard error) and the range of the confidence intervals.

---

## Analysis

We have draw a sample randomly of size N from a fixed population. After running the regression to see treatment effects we are getting values for beta, standard mean error, pvalues and confidence intervals. 

---

## Results Table for different sizes of sizes

| Size (N) | Mean of beta estimate | Mean Standard error | Mean Lower Conf.Int  | Mean Upper Conf.Int |
|-----------------|-----------|----------|----------------|----------------|
| 10              | 9.62      | 6.55     | -5.47          | 24.76          |
| 100             | 9.78      | 2.00     | 5.79           | 13.76          |
| 1,000           | 9.91      | 0.62     | 8.68           | 11.14          |
| 10,000          | 9.92      | 0.19     | 9.53           | 10.31          |

For the above results, please see file summary_p1

---

## Interpretation of beta Estimates

As the sample is smaller, the estimates will vary a lot as we see on our graphs. We can also see that the confidence intervals, the range is big, and as a result this estimates are far from the true effect. Therefore, the regression results are not useful as the information is noisy. Now  interestingly, as the sample increases the estimates get closer to 10. But the important thing is that the standar error is smaller every time, and also the confidcen intervals as well. This is more reliable regressions and useful models.

For the above results, please see the following file. [Click here, Graph of the estimates of beta](graph_beta.pdf)

---

# Part 2: Sampling Noise in an Infinite Superpopulation

## Objective of the section

We are exploring how the reuslts of a regression would come up, when we get samples from an infinite population. Every time we are extracting a new sample, of different sizes, create a regression and see how the beta changes across each sizes, but in this case is an infinite population.

---

## Analysis

We have draw a sample randomly of size N from an infinite population. After running the regression to see treatment effects we are getting values for beta, standard mean error, pvalues and confidence intervals. 

---

## Results Table for different sizes of sizes

| Size N       | Estimate of Beta | Standard Error | Low Conf.Int | Up Conf.Int |
|--------------|------------------|----------------|--------------|-------------|
| 4            | 9.21             | 9.21           | -29.15       | 50.07       |
| 8            | 9.90             | 7.32           | -7.98        | 27.87       |
| 10           | 9.94             | 6.65           | -5.32        | 25.35       |
| 16           | 10.28            | 5.16           | -0.80        | 21.36       |
| 32           | 10.10            | 3.55           | 2.84         | 17.35       |
| 64           | 10.03            | 2.51           | 5.00         | 15.05       |
| 100          | 9.83             | 2.01           | 5.84         | 13.83       |
| 128          | 9.85             | 1.77           | 6.35         | 13.36       |
| 256          | 10.01            | 1.25           | 7.54         | 12.48       |
| 512          | 9.99             | 0.89           | 8.25         | 11.73       |
| 1000         | 10.03            | 0.63           | 8.79         | 11.27       |
| 1024         | 10.00            | 0.63           | 8.77         | 11.23       |
| 2048         | 10.01            | 0.44           | 9.14         | 10.88       |
| 4096         | 9.97             | 0.31           | 9.35         | 10.58       |
| 8192         | 9.98             | 0.22           | 9.55         | 10.42       |
| 10000        | 10.00            | 0.20           | 9.60         | 10.39       |
| 16384        | 10.00            | 0.16           | 9.69         | 10.31       |
| 32768        | 10.00            | 0.11           | 9.78         | 10.22       |
| 65536        | 10.00            | 0.08           | 9.85         | 10.15       |
| 100000       | 9.996            | 0.063          | 9.872        | 10.120      |
| 131072       | 10.00            | 0.055          | 9.89         | 10.11       |
| 262144       | 10.00            | 0.039          | 9.92         | 10.08       |
| 524288       | 9.998            | 0.028          | 9.944        | 10.052      |
| 1000000      | 10.00            | 0.020          | 9.96         | 10.04       |
| 1048576      | 10.00            | 0.020          | 9.96         | 10.04       |
| 2097152      | 10.00            | 0.014          | 9.97         | 10.03       |


For the above results, please see file summary_p2
---

## Interpretation of beta Estimates of part2

As the sample is smaller, in this scenario, the results are widely different form the above. In this case, they are not close to useful as they are varying a lot, without patterns. Now, as the sample gets larger, as happened above in part1, the estiamtes are getting closer to 10, the true beta. Standard error gets smaller and reliable and the confidence intervals get closer. With this we can conclude that always smaller samples will be noisier, as bigger the sample, the more accurate our betas (closer to true effect). Something to point out from the infinite populaiton to the fixed one, is that this populaiton gives more flexibility than the first one. 

For the above results, please see the following file. [Click here, Graph of betas](graph_beta2.pdf)

---

# Comparison of Par1 and Part 2

## Discussion

1. Why Can We Use Larger Samples in Part 2?
Because par1 population was fixed and we were taking samples from the same pool of population. For part2, we were creating a new  dataset each time, as it was an infinite number of population, not the same pool.
2. Why Are SEM and Confidence Intervals Different?
It is related to the above, as we are sampling from a different population each time on part2. On the other hand sampling from the same pool in part1, will render different intervals for the errors. Having different pool each time will result in better result, probability wise.
---

## Comparison table for both parts

| Size       | Part | beta | Std error   | Confidence interval low to up |
|---------|--------|-----------|---------|------------------------------|
| 4       | Part 2 | 9.206     | 9.206   | -29.15 to 50.07             |
| 8       | Part 2 | 9.904     | 7.324   | -7.98 to 27.87              |
| 10      | Part 1 | 9.628     | 6.557   | -5.47 to 24.77              |
| 10      | Part 2 | 9.936     | 6.651   | -5.32 to 25.35              |
| 16      | Part 2 | 10.279    | 5.165   | -0.80 to 21.36              |
| 32      | Part 2 | 10.097    | 3.552   | 2.84 to 17.35               |
| 64      | Part 2 | 10.026    | 2.513   | 5.00 to 15.05               |
| 100     | Part 1 | 9.782     | 2.009   | 5.79 to 13.77               |
| 100     | Part 2 | 9.834     | 2.013   | 5.84 to 13.83               |
| 128     | Part 2 | 9.854     | 1.772   | 6.35 to 13.36               |
| 256     | Part 2 | 10.010    | 1.254   | 7.54 to 12.48               |
| 512     | Part 2 | 9.991     | 0.886   | 8.25 to 11.73               |
| 1000    | Part 1 | 9.916     | 0.628   | 8.68 to 11.15               |
| 1000    | Part 2 | 10.029    | 0.633   | 8.79 to 11.27               |
| 1024    | Part 2 | 10.002    | 0.626   | 8.77 to 11.23               |
| 2048    | Part 2 | 10.011    | 0.442   | 9.14 to 10.88               |
| 4096    | Part 2 | 9.967     | 0.312   | 9.35 to 10.58               |
| 8192    | Part 2 | 9.982     | 0.221   | 9.55 to 10.42               |
| 10000   | Part 1 | 9.924     | 0.199   | 9.53 to 10.31               |
| 10000   | Part 2 | 9.997     | 0.200   | 9.60 to 10.39               |
| 16384   | Part 2 | 9.999     | 0.156   | 9.69 to 10.31               |
| 32768   | Part 2 | 9.999     | 0.110   | 9.78 to 10.22               |
| 65536   | Part 2 | 10.000    | 0.078   | 9.85 to 10.15               |
| 100000  | Part 2 | 9.996     | 0.063   | 9.87 to 10.12               |
| 131072  | Part 2 | 10.001    | 0.055   | 9.89 to 10.11               |
| 262144  | Part 2 | 10.000    | 0.039   | 9.92 to 10.08               |
| 524288  | Part 2 | 9.998     | 0.028   | 9.94 to 10.05               |
| 1000000 | Part 2 | 10.000    | 0.020   | 9.96 to 10.04               |
| 1048576 | Part 2 | 10.000    | 0.020   | 9.96 to 10.04               |
| 2097152 | Part 2 | 10.001    | 0.014   | 9.97 to 10.03               |


For the above results, please see file comparison_summary

---

## Graphs for comparison

For the above results, please see the following file. [Click here, Graph of for comparison](graph_error_comparison.pdf)

For the above results, please see the following file. [Click here, Graph of mean estimates](graph_estimates_comparison.pdf)

For the above results, please see the following file. [Click here, Graph of std error](graph_stderror_comparison.pdf)
