---
title: 'Using R on the command line'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How do you run R on the HPCC through the command line?
- How can I create plots when I'm not using a graphical interface?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Demonstrate how to find and load a desired version of R using the module system
- Demonstrate how to start an R console
- Demonstrate how to run R scripts with the `RScript` command

::::::::::::::::::::::::::::::::::::::::::::::::

## Accessing the HPCC through the terminal

Up to now, we've been using RStudio through OnDemand to write and run R code on
the HPCC. Now, we'll do the same things we've been doing, but solely through the
command line. This will allow us to eventually [submit SLURM batch
scripts](r-slurm-jobs.Rmd) to run our code on compute nodes.

For now, we'll start by running everything on a development node. Using our
[previous instructions to SSH into a development
node](rstudio-ondemand.Rmd#ssh), we can get a command line running on a
development node. As a reminder, from a personal terminal, this looks something
like

```bash
ssh <netid>@hpcc.msu.edu
ssh <dev-node>
```

Make sure to use `dev-intel16` since [it matches the node type we used in OnDemand](managing-r-env-packages.Rmd#a-note-about-node-type).

## Loading R

The command to run an R console from the command line is just `R`! 

```bash
R
```

```output
R version 4.3.2 (2023-10-31) -- "Eye Holes"
Copyright (C) 2023 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale
  
R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

>
```

This started up R version 4.3.2 with no problems, but there's more going on
behind the scenes. In particular, by default, this version will not have access
to many additional packages pre-installed on the HPCC (run `.libPaths()` or
`lapply(.libPaths(), list.files)` to check).

The HPCC packages up all of its available software into **modules** so that not
every piece of software is available to everyone all of the time. To get access
to R, we have to load its module.

Let's first start by finding the version we're interested in. We'll use the
`module spider` command which searches through all the modules for the ones we
want:

```bash
module spider R
```

```output
----------------------------------------------------------------------------
  R:
----------------------------------------------------------------------------
    Description:
      R is a free software environment for statistical computing and
      graphics.

     Versions:
        R/3.6.3-foss-2022b
        R/4.2.2-foss-2022b
        R/4.3.2-gfbf-2023a-ICER
        R/4.3.2-gfbf-2023a
        R/4.3.3-gfbf-2023b
        R/4.4.1-gfbf-2023b
     Other possible modules matches:
        ADMIXTURE  AOFlagger  APR  APR-util  Amber  Armadillo  Arrow  ...
...
```

We've abbreviated the output, but we can see that there are lots of different versions of R available! But note that none of these mention anything about extra packages like the versions in OnDemand do.

These are the **base** versions of R. To get access to more R packages that build on these base versions, you need to look for *bundles*:

``` bash
module spider R-bundle
```

``` output
----------------------------------------------------------------------------
  R-bundle-Bioconductor:
----------------------------------------------------------------------------
    Description:
      Bioconductor provides tools for the analysis and coprehension of
      high-throughput genomic data.

     Versions:
        R-bundle-Bioconductor/3.16-foss-2022b-R-4.2.2
        R-bundle-Bioconductor/3.18-foss-2023a-R-4.3.2

----------------------------------------------------------------------------

...

----------------------------------------------------------------------------
  R-bundle-CRAN:
----------------------------------------------------------------------------
    Description:
      Bundle of R packages from CRAN

     Versions:
        R-bundle-CRAN/2023.12-foss-2023a
        R-bundle-CRAN/2024.06-foss-2023b

----------------------------------------------------------------------------
...
```

Note that the bundles are versioned differently (by year instead of R version). The best way to see which version of R is included is to load one and run R.

``` bash
module purge
module load R-bundle-CRAN/2023.12-foss-2023a
R
```

``` output
R version 4.3.2 (2023-10-31) -- "Eye Holes"
Copyright (C) 2023 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.


Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

>
```

Great! This matches the exact R module that RStudio was using in OnDemand.

We now have an R console where we can run short lines of code, just like from RStudio. As the output from `R` shows, type `q()` to quit and return back to the command line. 

If you're asked to save the workspace image, it's best practice to say no since this can lead to long load times and less reproducible sessions in the future.
In fact, you can use the `--vanilla` option when starting R to ensure it ignores things like your `.Renviron` and `.Rprofile` changes.
We will use this option below to make sure we run our code in the cleanest environment possible.

::::::::::::::::::::::::::::::: callout

## Loading external dependencies

[As mentioned when we were installing packages](managing-r-env-packages.Rmd#do-your-packages-require-external-dependencies), sometimes R packages need external dependencies to install and run.
When you load the R module using the `module load` commands above (before you actually run `R`), this is also the time to load those external dependencies.

Note that these dependencies and R will all need to be be compatible (e.g., use the same version of GCC and MPI).
For example, a Bayesian modeling workflow might require the use of JAGS as dependencies for R packages.
After loading R and its dependencies with

```bash
module purge
module load R-bundle-CRAN/2023.12-foss-2023a
```

you can try loading a compatible JAGS module without specifying a version:

```bash
module load JAGS
```

Then check which version gets loaded:

```bash
module list
```
```output
Currently Loaded Modules:
  1) GCCcore/12.3.0
  2) zlib/1.2.13-GCCcore-12.3.0
  ...
127) R-bundle-CRAN/2023.12-foss-2023a
128) JAGS/4.3.2-foss-2023a
```

If this version will work, then great! 
If not, then you might try using a different version of R.
Usually, newer versions of dependencies for popular R packages get installed with newer versions of R.

For more on finding and loading modules, checkout [ICER's module documentation](https://docs.icer.msu.edu/Intro_to_modules/).

:::::::::::::::::::::::::::::::::::::::

## Running one-liners and scripts with `RScript`

The R console is great for interactive work. But sometimes we might want to just send some code to R to run and give us back the answer. For this, we use the `Rscript` command.

First, let's start by sending `Rscript` a single command using the `-e` flag (which stands for "expression"):

```bash
Rscript --vanilla -e 'date()'
```

```output
[1] "Tue Jan  7 17:29:05 2025"
```

We get the same output as if we had run `date()` in an R console or in a script! Note that we have to wrap the expression we want to run in single quotes.

We can run multiple expressions at once. For example, let's get the quotient and remainder of 128 divided by 11:

```bash
Rscript --vanilla -e '128 %/% 11' -e '128 %% 11'
```

```output
[1] 11
[1] 7
```

The real power of `Rscript` comes into play when we have an actual script to run! Let's run our previous one. `Rscript` takes the path to the script as argument. We'll first change directory to the location of our script so we don't need to specify the entire path name.

```bash
cd ~/r_workshop
Rscript src/test_sqrt_multisession.R
```

```output
   user  system elapsed 
  0.238   0.003   1.698
```

This is the equivalent of clicking the Source button while we have a R script open in RStudio, or running `source('~/r_workshop/src/test_sqrt_multisession.R')` from an R console.
Notice that we didn't use the `--vanilla` option here.
This ensures that we use the local library setup in the project directory.


## Writing scripts that take command line arguments

Often, you will want to be able to pass extra arguments to your scripts when you run them from the command line. The simplest way is to use the `commandArgs` function in R which lets us access all of the command line arguments as a character vector.

From the command line, open a new R script called `src/command_args.R` in a text editor of your choice. If you aren't familiar with any, a good option is `nano`.

```bash
nano src/command_args.R
```

Our script will print out all of our command line arguments:

```r
args <- commandArgs(trailingOnly = TRUE)
nargs <- length(args)

for(i in 1:nargs) {
  cat("Argument", i, ":", args[i], "\n")
}
```

It's important to use the `trailingOnly = TRUE` option with `commandArgs` so that we only get the arguments after the name of the script.

If you're using `nano`, after typing the above code, press `ctrl+o` followed by `enter` to save, then `ctrl+x` to exit.

We can now run our script through `Rscript` with some arguments:

```bash
Rscript --vanilla src/command_args.R a b c
```

```output
Argument 1 : a 
Argument 2 : b 
Argument 3 : c 
```

For a more sophisticated way to handle command line arguments (including flags, automated usage messages, default options, and more), check out [optparse](https://cran.r-project.org/web/packages/optparse/).

:::::::::::::::::::::::::::::::: challenge

Write an Rscript one-liner to print the numbers from 1 to 10.

:::::::::::::::::::::::: solution

```bash
Rscript --vanilla -e 'for(i in 1:10) print(i)'
```
:::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::: challenge

Write an Rscript one-liner to display the `help` for the function `strtoi` (press "q" to exit).

:::::::::::::::::::::::: solution

```bash
Rscript --vanilla -e 'help(strtoi)'
```
:::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::: challenge

Write an Rscript that takes an integer as a command line argument and prints the numbers from 1 to that integer.

:::::::::::::::::::::::: solution

```r
args <- commandArgs(trailingOnly = TRUE)
n <- strtoi(args[1])

for(i in 1:n) {
  print(i)
}
```
:::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::: challenge

Copy `test_sqrt_multisession.R` into a new R script and modify it to take an integer as a command line argument. Use the command line argument to set the number of iterations in the `foreach` loop. Additionally, make sure that the script handles the case when no command line argument is passed (you can choose the desired behavior).

:::::::::::::::::::::::: solution

```r
library(foreach)
library(doFuture)
plan(multisession, workers = 5)

args <- commandArgs(trailingOnly = TRUE)

num_runs = 10  # default to 10 runs
if (length(args) > 0) {
  num_runs <- strtoi(args[1])
}

t <- proc.time()

x <- 1:num_runs
z <- foreach(xi = x) %dofuture% {
  Sys.sleep(0.5)
  sqrt(xi)
}

print(proc.time() - t)
```
:::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::

## Plotting with the command line

You may wonder how you might run a plot using the terminal interface?   For most terminals, if you plot with the command line version of R, either nothing happens or there is an error message.  It may work on some terminals, if X11 Linux graphical interface is installed and the terminal is an X11-capable (for example on MacOS is 'Quartz' is installed, a new windows will appear).  However when running in 'batch' mode using the cluster (described in the next session), there is no interface at all. 

There are the following techniques for handling plots when using R on the command line on HPCC

- split your code into computation and presentation sections:  run computation section using CLI/Batch on HPC, and after the computation is complete, save the output to be read into visualization code that you run on a machine with a graphic user interface (OnDemand Rstudio, or even your laptop)
- capture all output to a file using commands like PDF()
- as part of your script, create an RMarkdown file that includes plotting (or other output), and use the [render](https://rmarkdown.rstudio.com/docs/reference/render.html) command in Rmarkdown to PDF or other format to be review later

We'll describe the method to capture output into a PDF here.   

A sample script that uses the `pdf` function to capture plots looks like this: 

```r
plotfile = file.path('results', 'testplots.pdf')
pdf(plotfile)

plot(iris$Petal.Length, iris$Petal.Width, pch=21,
     bg=c("red","green3","blue")[unclass(iris$Species)],
     main="Edgar Anderson's Iris Data")

dev.off()
```

In order to run this code, we first have to create the results directory on the command line with

``` bash
mkdir results
```

For much more details about using this techinque, see 
[Chapter 14 Output for Presentation](https://r-graphics.org/chapter-output) of Winston Chang's **R Graphics Cookbook** 

Once you run the script and save the PDFs, the next challenge is to view them because, again, the terminal does not have the GUI to view PDFs.  

You could

 - download the PDF to your computer from the terminal using OnDemand file browser (or the MobaXterm client's file browser)
 - open with the OnDemand RStudio. 
 
 

:::::::::::::::::::::::::::::::: challenge

One of the challenges with running scripts repeatedly is that it will overwrite the plot file with the same name.  Modify the plotting script above that accepts a command line parameter for the the name of the PDF file.  BONUS: how would you handle the case where there was no command line argument sent?

:::::::::::::::::::::::: solution

```r
args <- commandArgs(trailingOnly = TRUE)

# check if there was at least 1 arg
if length(args) >= 1 {

   #assume the arg is a PDF file name, and use that to capture plots
   plotfile = args[1]
   pdf(plotfile)

}

# if not argument is sent, PDF capture is not enabled and the plot will display

plot(iris$Petal.Length, iris$Petal.Width, pch=21,
     bg=c("red","green3","blue")[unclass(iris$Species)],
     main="Edgar Anderson's Iris Data")
     
dev.off()

```
:::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::



::::::::::::::::::::::::::::::::::::: keypoints 

- Use `module spider R` to see the available versions of R on the HPCC
- Use `module spider R-bundle` to see the available bundles (including extra R packages) on the HPCC
- Use `module load ...` to get access to the desired version of R (or a bundle)
- Run `R` from the command line to start an interactive R console
- Use the `--vanilla` option to ignore extra configuration files
- Run `Rscript` to run an R script
- Use `commandArgs` to parse command line arguments in an R script
- Use `pdf()` to capture plotting into a PDF file

::::::::::::::::::::::::::::::::::::::::::::::::

