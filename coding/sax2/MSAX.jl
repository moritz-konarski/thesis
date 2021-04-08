# get data

# mean vector
μ = mean(data, dims = 2) # Statistics

# covariance matrix
Σ = cov(data, dims = 2) # Statistics

# normalization
d = √(inv(Σ)) * ( data .- μ )

# for each lead: apply PAA

# use SAX cut points to discretize time series
# use different capitalization for the different time series

uppercase('a') # to make second version, broadcase with . for vector