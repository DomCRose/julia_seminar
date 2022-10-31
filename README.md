# Intro to Julia seminar

This repository contains the presentation slides, live demo code and supporting code materials for a talk aimed at introducing the Julia programming language, focused on how it is different and the parts of its design that enable abstract, generic code to compile into a fast program. As such much time is spent on demonstrating multiple dispatch and the type system, though the lense of simple stochastic (i.e. random dynamical) simulations. It was aimed at those who already have quite a bit of coding experience, e.g. those who code daily for their work as research scientists or software developers.

The code folder contains:
* multiple_dispatch.jl: Contains code for the fourth slide of the presentation introducing multiple dispatch.
* basics.ipynb: Python code for comparison with the start of the Julia file basics.jl.
* basics.jl: The code for the live demo. Beginning with a basic for loop and vectorized code (for comparison with the equivalent python for loop, vectorized and Numba compiled code in basics.ipynb), the bulk of the demo is dedicated to gradually introducing some of the type system by seeing how it can be used to make the code more abstract / flexible without any loss of speed. The demo code ends with a brief look at how to easily make use of multithreading, and how flexible broadcasting is.
* plotting.jl / plotting2.jl: contains code used to plot the trajectories produced by the simulations in the live demo.
* ad_and_ml.jl: Demonstrates some basic automatic differentiation (AD) usage, how to construct a neural network model using a particular package, and how to use the AD get the gradient of a loss function. Used for pictures in slide 8 of the presentation.
* gpu.jl: Building on the examples of the live demo, this file shows how code can be written to trivially work on both CPU and GPU, while still making use of abstraction to e.g. use the same code to simulate different dynamics, or use custom data types on the GPU. Used for images in the 9th slide of the presentation.
