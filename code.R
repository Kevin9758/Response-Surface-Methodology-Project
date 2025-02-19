## Goals of Response Surface Methodology


# Response Surface Methodology aims to conduct a sequence of experiments to obtain an
# optimal response variable, utilizing information from prior experiments to aid in 
# future ones.
# 
# This goal can be achieved by characterizing the relationship between the 
# expected response and a subset of the design factors. The set of possible values 
# that this subset of the factors can take is called the region of operability.
# This region is where we explore and run our experiments to find the optimal
# condition.
# 
# The function characterizing the relationship between the expected response
# and a subset of the design factors is unknown, so we fit models to approximate
# it. We typically use Taylor's Theorem and low order polynomials, especially
# in small localized regions of experiments, where low order polynomials should
# well approximate the function. However, second order models are used for response
# surface optimization since they are capable of modeling concavity/convexity.
# 
# An example of response surface methodology is using factor screening to identify
# factors that significantly influence the response variable, and then following
# up by optimizing that response with the method of steepest ascent/descent
# and response surface designs. Each experiment conducted uses information from
# previous ones and the goal is to find the optimal operating condition.





netflixffdp <- read.csv("netflixffd.csv", header = TRUE)
netflixffdc <- read.csv("netflixffd2.csv", header = TRUE)

netflixffdp$Prev.Length[netflixffdp$Prev.Length == 100] <- -1
netflixffdp$Prev.Length[netflixffdp$Prev.Length == 120] <- 1

netflixffdp$Match.Score[netflixffdp$Match.Score == 80] <- -1
netflixffdp$Match.Score[netflixffdp$Match.Score == 100] <- 1

netflixffdp$Tile.Size[netflixffdp$Tile.Size == 0.1] <- -1
netflixffdp$Tile.Size[netflixffdp$Tile.Size == 0.3] <- 1

netflixffdc$Prev.Length[netflixffdc$Prev.Length == 100] <- -1
netflixffdc$Prev.Length[netflixffdc$Prev.Length == 120] <- 1

netflixffdc$Match.Score[netflixffdc$Match.Score == 80] <- -1
netflixffdc$Match.Score[netflixffdc$Match.Score == 100] <- 1

netflixffdc$Tile.Size[netflixffdc$Tile.Size == 0.1] <- -1
netflixffdc$Tile.Size[netflixffdc$Tile.Size == 0.3] <- 1


m.factorial <- lm(Browse.Time ~  Prev.Length + Match.Score + Tile.Size , data = netflixffdp)

summary(m.factorial)


netflix <- rbind(netflixffdp, netflixffdc)


m.full <- lm(Browse.Time ~  Prev.Length * Match.Score * Tile.Size , data = netflix)

summary(m.full)


reduced = subset(netflix, select = -c(Prev.Type, Tile.Size))

m.reduced <- lm(Browse.Time ~  Prev.Length * Match.Score  , data = reduced)

summary(m.reduced)







# I began by trying a $2^{3-1}$ fractional factorial design with design generator
# Tile.Size = Prev.Length:Match.Score, resulting in the principle fraction design.
# Being a fractional factorial design, it only has half of the 8 conditions in a full $2^3$ design. However, each main 
# effect is aliased with a two factor interaction effect. 
# 
# The high levels for tile size, match score, and preview length are 0.3, 100, 120
# and the low levels are 0.1, 80, 100, respectively.
# After simulating the data and fitting the model, I found
# the output provided p-values associated with t-tests of the
# hypothesis $$H_0 : \beta = 0  \  \textrm{vs}  \  H_A : \beta \neq 0$$ for each regression
# coefficient in the model. The p-values for each main effect was significant. 
# However, due to confounding from the aliasing, there is no way to conclude if
# each main effect was really significant, or if it was due to a two factor interaction
# effect. 



Pvalues_fractional <- c("<2e-16","<2e-16","<2e-16")

Factors_fractional <- c("Preview Length", "Match Score", "Tile Size")

df1 <- data.frame(Factors_fractional,Pvalues_fractional)
# head(df1)

knitr::kable(df1, format = "markdown")

```

# Thus, I decided to sacrifice some efficiency for accuracy and simulated
# the other 4 conditions of the full $2^3$ model, which resulted in the complementary
# fraction design. 
# Thus, with all 8 conditions, I analyzed the experiment as a full $2^3$ design without any confounding.
# The output provided p-values associated with t-tests of the
# hypothesis $$H_0 : \beta = 0  \  \textrm{vs}  \  H_A : \beta \neq 0$$ for each regression
# coefficient in the model. The p-value for tile size was 0.787 > 0.01 so it is 
# not significant at the 1% level. In addition, all 2 factor interaction effects that included tile size
# are also not significant at a 1% level since their p-values are greater than 0.01
# as well. Thus I concluded that tile size does not significantly influence the
# response variable and I excluded it in future experiments.
# 



Pvalues_full <- c("<2e-16","<2e-16","0.787","<2e-16","0.613","0.709","0.342")
Factors_full <- c("Preview Length", "Match Score", "Tile Size", "Prev.Length:Match.Score"
              , "Prev.Length:Tile.Size", "Match.Score:Tile.Size", 
              "Prev.Length:Match.Score:Tile.Size")

df2 <- data.frame(Factors_full,Pvalues_full)
# head(df2)

knitr::kable(df2, format = "markdown")



# We can get the effects for the active factors by multiplying their $\hat\beta$ 
# estimates by 2.
# 
# Preview Length : $2\hat\beta$ = 1.76624. Thus, as compared to when preview length
# is 100, when preview length is 120, we expect the average browsing time to increase
# by 1.76624 minutes
# 
# Match Score : $2\hat\beta$ = 1.85906. Thus, as compared to when match score
# is 80, when preview length is 100, we expect the average browsing time to increase
# by 1.85906. minutes



par(mfrow = c(1, 2))
# m.full <- lm(Browse.Time ~  Prev.Length * Match.Score * Tile.Size , data = netflix)
# 
# summary(m.full)

moi.by.P <- aggregate(x = netflix$Browse.Time, by = list(Preview.Length = netflix$Prev.Length), FUN = mean)
plot(x = c(-1, 1), y = moi.by.P$x, pch = 16, main = " Main effect Preview Length",
     ylab = "Avg Browsing Time)", xlab = "Preview Length", xaxt = "n")
lines(x = c(-1, 1), y = moi.by.P$x)
axis(side = 1, at = c(-1, 1), labels = c("100", "120"))

moi.by.M <- aggregate(x = netflix$Browse.Time, by = list(Match.Score = netflix$Match.Score), FUN = mean)
plot(x = c(-1, 1), y = moi.by.M$x, pch = 16, main = " Main effect Match Score",
     ylab = "Avg Browsing Time)", xlab = "Match Score", xaxt = "n")
lines(x = c(-1, 1), y = moi.by.M$x)
axis(side = 1, at = c(-1, 1), labels = c("80", "100"))


```
# 
# The main effects plots agree with the results from earlier. Browsing time seems
# to increase as match score increases from 80 to 100 and preview length increases
# from 100 to 120.
# 
# In conclusion, I have found that tile size does not significantly influence the
# average browsing time, and I will exclude it in further phases. The factors
# that I have found that significantly influence browsing time
# are preview length and match score.










# After factor screening, I ended up with 2 factors, preview length and match score,
# that I had found to significantly influence browsing time.
# 
# I then wanted to roughly determine the optimal levels for these 2 factors.
# 
# I began with a $2^2$ factorial experiment with a center point condition. The
# initial region of experimentation was the area in which my factor screening 
# took place. Thus, the high level for preview length was 120 and low level for it
# was 100. The high level for match score was 100 and low level was 80.
# 
# I first simulated the data for the center point and combined it with previously simulated 
# data and then performed a curvature test in order to determine whether the initial region was already in the vicinity of
# the optimum.
# 
# I found that although $\beta_{PQ}$ was significantly different
# from 0, since its p-value was much lower than 0.01, its size was much larger relative to 
# the other p-values. Thus, there was likely not a pure quadratic curvature in this area and so
# the initial region was not likely to be in the vicinity of the optimum.







netflixffd1 <- read.csv("netflixffd.csv", header = TRUE)
netflixffd2 <- read.csv("netflixffd2.csv", header = TRUE)

netflix <- rbind(netflixffd1, netflixffd2)

phase2data = subset(netflix, select = -c(Prev.Type, Tile.Size))

# Function to create blues
blue_palette <- colorRampPalette(c(rgb(247,251,255,maxColorValue = 255), rgb(8,48,107,maxColorValue = 255)))

# Function for converting from natural units to coded units
convert.N.to.C <- function(U,UH,UL){
  x <- (U - (UH+UL)/2) / ((UH-UL)/2)
  return(x)
}

# Function for converting from coded units to natural units
convert.C.to.N <- function(x,UH,UL){
  U <- x*((UH-UL)/2) + (UH+UL)/2
  return(U)
}

center <- read.csv("center.csv", header = TRUE)

center = subset(center, select = -c(Prev.Type, Tile.Size))

phase2 <- rbind(phase2data, center)


# Function to create x and y grids for contour plots 
mesh <- function(x, y) { 
  Nx <- length(x)
  Ny <- length(y)
  list(
    x = matrix(nrow = Nx, ncol = Ny, data = x),
    y = matrix(nrow = Nx, ncol = Ny, data = y, byrow = TRUE)
  )
}

## Determine whether we're close to the optimum to begin with
## (i.e, check whether the pure quadratic effect is significant)
ph1p <- data.frame(y = phase2$Browse.Time,
                   x1 = convert.N.to.C(U = phase2$Prev.Length, UH = 120, UL = 100),
                   x2 = convert.N.to.C(U = phase2$Match.Score, UH = 100, UL = 80))
ph1p$xPQ <- (ph1p$x1^2 + ph1p$x2^2)/2
## Check the average browsing time in each condition:
#aggregate(ph1p$y, by = list(x1 = ph1p$x1, x2 = ph1p$x2), FUN = mean)

## The difference in average browsing time in factorial conditions vs. the center 
## point condition
#mean(ph1p$y[ph1p$xPQ != 0]) - mean(ph1p$y[ph1p$xPQ == 0])


## Check to see if that's significant
m <- lm(y~x1+x2+x1*x2+xPQ, data = ph1p)
#summary(m)


pvalues <- c("<2e-16","<2e-16","1.05e-07","<2e-16")

coefficients <- c("x1", "x2", "xPQ", "x1:x2")

df3 <- data.frame(coefficients,pvalues)
# head(df1)

#knitr::kable(df3, format = "markdown")




# My next step was to use the method of steepest descent in order to determine
# roughly where in the x-space the optimum was lying.
# 
# I first fitted the first order model to determine the direction of the path
# of the steepest descent.
# I also found the 2D contour plot, with the gradient on it and we see that the
# starting point is (0,0).



mp.fo <- lm(y~x1+x2, data = ph1p)
beta0 <- coef(mp.fo)[1]
beta1 <- coef(mp.fo)[2]
beta2 <- coef(mp.fo)[3]
grdp <- mesh(x = seq(convert.N.to.C(U = 30, UH = 120, UL = 100), 
                     convert.N.to.C(U = 120, UH = 120, UL = 100), 
                     length.out = 100), 
             y = seq(convert.N.to.C(U = 0, UH = 100, UL = 80), 
                     convert.N.to.C(U = 100, UH = 100, UL = 80), 
                     length.out = 100))
x1 <- grdp$x
x2 <- grdp$y
etap.fo <- beta0 + beta1*x1 + beta2*x2

# 2D contour plot
contour(x = seq(convert.N.to.C(U = 30, UH = 120, UL = 100), 
                convert.N.to.C(U = 120, UH = 120, UL = 100), 
                length.out = 100),
        y = seq(convert.N.to.C(U = 0, UH = 100, UL = 80), 
                convert.N.to.C(U = 100, UH = 100, UL = 80), 
                length.out = 100), 
        z = etap.fo, xlab = "x1 (Preview Length)", ylab = "x2 (Match Score",
        nlevels = 15, col = blue_palette(15), labcex = 0.9, asp=1)
abline(a = 0, b = beta2/beta1, lty = 2)
points(x = 0, y = 0, col = "red", pch = 16)

## Calculate the coordinates along this path that we will experiment at

# The gradient vector
g <- matrix(c(beta1, beta2), nrow = 1)




# We will take steps of size 5 seconds in preview length. In coded units this is
PL.step <- convert.N.to.C(U = 110 + 5, UH = 120, UL = 100)
lamda <- PL.step/abs(beta1)


## Step 0: The center point we've already observed
x.old <- matrix(0, nrow=1, ncol=2)
text(x = 0, y = 0+0.25, labels = "0")
step0 <- data.frame(Prev.Length = convert.C.to.N(x = 0, UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = 0, UH = 100, UL = 80)))

## Step 1: 
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "1")
step1 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 2: 
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "2")
step2 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 3: 
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "3")
step3 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 4: 
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "4")
step4 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 5: 
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "5")
step5 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 6: 
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "6")
step6 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

## Step 7:
x.old <- x.new
x.new <- x.old - lamda*g
points(x = x.new[1,1], y = x.new[1,2], col = "red", pch = 16)
text(x = x.new[1,1], y = x.new[1,2]+0.25, labels = "7")
step7 <- data.frame(Prev.Length = convert.C.to.N(x = x.new[1,1], UH = 120, UL = 100), 
                    Match.Score = round(convert.C.to.N(x = x.new[1,2], UH = 100, UL = 80)))

pstdf.cond <- data.frame(Step = 0:7, rbind(step0, step1, step2, step3, step4, step5, step6, step7))
#pstdf.cond




# Since preview length can only be changed in increments of 5, I decided that the
# steps should be 5 seconds long in preview length. I then converted it from natural
# units to coded units. I got that $\Delta x_1 = 0.5$ and so $\lambda = \frac{0.5}{\hat\beta_1}$ = 0.5661741.
# 
# I took one step at a time, until I found the lowest observed average browsing time,
# and then I took a few more to make sure that I had found the lowest, since the 
# following steps ended up with higher average browsing time.



## Load the data associated with the steepest descent search
ptsdf <- read.csv("ptsdf.csv", header = TRUE)
ptsdf = subset(ptsdf, select = -c(Prev.Type, Tile.Size))

phase3 <- rbind(ptsdf, center)


## Calculate the average browsing time in each of these conditions and find the 
## condition that minimizes it
pstdf.means <- aggregate(phase3$Browse.Time, 
                         by = list(Prev.Length = phase3$Prev.Length, 
                                   Match.Score = phase3$Match.Score), 
                         FUN = mean)

plot(x = 0:7, y = rev(pstdf.means$x),
     type = "l", xlab = "Step Number", ylab = "Average Browsing Time")
points(x = 0:7, y = rev(pstdf.means$x),
       col = "red", pch = 16)

#pstdf.cond[pstdf.cond$Step == 4,]


p3final <- read.csv("p3.csv", header = TRUE)
ph2.5 <- data.frame(y = p3final$Browse.Time,
                    x1 = convert.N.to.C(U = p3final$Prev.Length, UH = 100, UL = 80),
                    x2 = convert.N.to.C(U = p3final$Match.Score, UH = 80, UL = 60))
ph2.5$xPQ <- (ph2.5$x1^2 + ph2.5$x2^2)/2

## Check the average browsing time in each condition:
#aggregate(ph2.5$y, by = list(x1 = ph2.5$x1, x2 = ph2.5$x2), FUN = mean)

## The difference in average browsing time in factorial conditions vs. the center 
## point condition
#mean(ph2.5$y[ph2.5$xPQ != 0]) - mean(ph2.5$y[ph2.5$xPQ == 0])

## Check to see if that's significant
m <- lm(y~x1+x2+x1*x2+xPQ, data = ph2.5)
#summary(m)



# I found that step 4 corresponded to the lowest observed average browsing time.
# It corresponded to a preview length of 90 seconds and match score of 70%.
# 
# In order to determine if I reached the vicinity of the optimum, I decided to perform
# another test of curvature in this region. I ran another $2^2$ factorial experiment with
# a center point and simulated the data. My new high level for preview length was 100, and low level was 80.
# My new high level for match score was 80, and low level was 60.
# 
# This time, $\beta_{PQ}$ was significantly
# different from 0 and the p-value for the pure quadratic was <2e-16 < 0.01, so I rejected
# the null hypothesis that the pure quadratic was 0. Thus, I concluded that I was
# in the vicinity of the optimum.
# The optimal browsing time was somewhere in the vicinity of 90 seconds for
# preview length, and 70% for match score.






# I decided to follow up my results with a response surface experiment so
# that a full second order model could be fit and the optimum identified. I have
# already identified the significant factors though factor screening,
# and found a rough idea of where the optimum lies through the method of 
# steepest descent.
# 
# The response surface experiment that I decided to use was the central composite
# design. A central composite design facilitates estimation of the full second
# order response surface model, and hence identification of the optimum.



# Function to create blues
blue_palette <- colorRampPalette(c(rgb(247,251,255,maxColorValue = 255), rgb(8,48,107,maxColorValue = 255)))

# Function for converting from natural units to coded units
convert.N.to.C <- function(U,UH,UL){
  x <- (U - (UH+UL)/2) / ((UH-UL)/2)
  return(x)
}

# Function for converting from coded units to natural units
convert.C.to.N <- function(x,UH,UL){
  U <- x*((UH-UL)/2) + (UH+UL)/2
  return(U)
}

# Function to create x and y grids for contour plots 
mesh <- function(x, y) { 
  Nx <- length(x)
  Ny <- length(y)
  list(
    x = matrix(nrow = Nx, ncol = Ny, data = x),
    y = matrix(nrow = Nx, ncol = Ny, data = y, byrow = TRUE)
  )
}





# I chose the high and low levels of the factors based on the center point
# being my estimate of the optimum from steepest descent in phase 2. I also
# chose the high and low levels based on my selection of a spherical design in
# order to ensure the estimate of the response surface at each condition is
# equally precise.



ccdata <- read.csv("sphere.csv", header = TRUE)

condition <- data.frame(x1 = convert.C.to.N(x = c(-1,-1,1,1,0,1.5,-1.5,0,0), UH = 110, UL = 70), 
                        x2 = convert.C.to.N(x = c(-1,1,-1,1,0,0,0,1.5,-1.5), UH = 90, UL = 50))

pi_hat <- aggregate(x = ccdata$Browse.Time, by = list(condition.num = kronecker(1:9, rep(1, 100))), FUN = mean)
df3 <- data.frame(Condition.Num = pi_hat$condition.num, 
                  Prev.Length = condition$x1, 
                  Match.Score = condition$x2,
                  Browse.Time = pi_hat$x)

knitr::kable(df3, format = "markdown")




# I intended to perform axial conditions with $a$ = $\sqrt{2}$, but the corresponding
# preview times and match scores were messy. Thus, in the interest of defining
# experimental conditions with more convenient levels, I let $a$ = 1.5, yielding
# the preview lengths and match scores in the table above. I then generated data
# simulating 100 users randomized into each of these 9 conditions, and recorded
# their browsing time.



par(mfrow = c(1, 2))

ph3 <- data.frame(y = ccdata$Browse.Time,
                  x1 = convert.N.to.C(U = ccdata$Prev.Length, UH = 110, UL = 70),
                  x2 = convert.N.to.C(U = ccdata$Match.Score, UH = 90, UL = 50))



## Check to see if that's significant

model <- lm(y ~ x1 + x2 + x1*x2 + 
              I(x1^2) + I(x2^2), data = ph3)

#summary(model)


beta0 <- coef(model)[1]
beta1 <- coef(model)[2]
beta2 <- coef(model)[3]
beta12 <- coef(model)[6]
beta11 <- coef(model)[4]
beta22 <- coef(model)[5]
grd <- mesh(x = seq(convert.N.to.C(U = 30, UH = 110, UL = 70), 
                    convert.N.to.C(U = 120, UH = 110, UL = 70), 
                    length.out = 100), 
            y = seq(convert.N.to.C(U = 0, UH = 90, UL = 50), 
                    convert.N.to.C(U = 100, UH = 90, UL = 50), 
                    length.out = 100))
x1 <- grd$x
x2 <- grd$y
eta.so <- beta0 + beta1*x1 + beta2*x2 + beta12*x1*x2 + beta11*x1^2 + beta22*x2^2

contour(x = seq(convert.N.to.C(U = 30, UH = 110, UL = 70), 
                convert.N.to.C(U = 120, UH = 110, UL = 70), 
                length.out = 100), 
        y = seq(convert.N.to.C(U = 0, UH = 90, UL = 50), 
                convert.N.to.C(U = 100, UH = 90, UL = 50), 
                length.out = 100), 
        z = eta.so, xlab = "x1", ylab = "x2",
        nlevels = 25, col = blue_palette(20), labcex = 0.9)

b <- matrix(c(beta1,beta2), ncol = 1)
B <- matrix(c(beta11, 0.5*beta12, 0.5*beta12, beta22), nrow = 2, ncol = 2)
x.s <- -0.5*solve(B) %*% b 
points(x = x.s[1], y = x.s[2], col = "red", pch = 16)


#x.s[1]
#x.s[2]




# The predicted browsing time at this configuration is:
eta.s <- beta0 + 0.5*t(x.s) %*% b
# eta.s

# convert.C.to.N(x = x.s[1,1], UH = 110, UL = 70)
# convert.C.to.N(x = x.s[2,1], UH = 90, UL = 50)

contour(x = seq(30, 120, length.out = 100), 
        y = seq(0, 100, length.out = 100), 
        z = eta.so, xlab = "Preview Length (seconds)", ylab = "Match Score",
        nlevels = 20, col = blue_palette(20), labcex = 0.9)

points(x = convert.C.to.N(x = x.s[1,1], UH = 110, UL = 70),
       y = convert.C.to.N(x = x.s[2,1], UH = 90, UL = 50), 
       col = "red", pch = 16)

points(x = 90, y = 70, pch = 16, col = "green")


```
# I then fit the full second order response surface by fitting the second order
# regression model.
# 
# From the coefficients in the output, I plotted the contour plot in coded units
# and found that the stationary point was located at $x_1$ = -0.9266421 and 
# $x_2$ = 0.3571865.
# 
# I then converted the contour plot to natural units. The corresponding stationary
# point is when preview length is 71.47 (70) seconds and match score is 77.14% (77%),
# represented by the red point. The green point is my rough estimate of the
# optimal conditions from using the method of steepest descent in phase 2. It
# suggested a preview length of 90 seconds and a match score of 70%.
# As can be seen, it is somewhat close to the true optimum. 
# 
# The estimated browsing time at the optimum is 11.53 seconds and a 95% confidence interval is given by 
# (11.3855,11.675).
# 
# Thus, Netflix should utilize preview lengths of 70 seconds and match scores of 77%
# in order to minimize the browsing time by users.










