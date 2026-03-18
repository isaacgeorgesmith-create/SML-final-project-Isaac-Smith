**Math and Model**

**Model Choice**

The goal of this ML model is to predict the measured ionic current throughout the simulation, given a time varying applied electric field throughout the simulation. If the system was homogenous in the z direction, the response to the electric field would likely be almost entirely resistive, so the current would closely follow Ohm's Law: $I \propto E_\text{applied}$. However, this system is not homogenous. As a mobile ion moves along the z direction, it encounters alternating bands of fixed cations and fixed anions, with each band being $15 \sigma$ wide ($\sigma$ = 1 ion diameter). This creates a capacitative effect, as mobile ions are repelled from regions containing like, fixed charges, so Ohm's law does not describe the situation well. We could try to model the current analytically, but this system (as well as the real, physical diodes we are interested in) is quite dense; with 6000 ions, 26% of the space in the box is taken up by ions, so excluded volume effects, which are difficult to precisely model analytically are important. Additionally, while the boundary between the polycationic and polyanionic regions is a flat plane in this simulation, it is not so smooth on the molecular scale in reality, and we are interested in potentially having a more complicated geometry for the interface in the future, which would further complicate matters. There may also be small slightly inductive components to the response, since the ions have nonzero mass, so their inertia should resist changes in current flow, but these effects are too small to be noticed at the relatively low frequencies of electric field we are using.

Since there is at least a component of the current that is proportional to the electric field, and in some cases that can be quite a large component, I chose to model the residual between the current and electric field, with the units and normalization of current chosen so that the proportionality constant in Omhs law is 1. Then, I use a Deep O Met to predict the residual. I use a neural operator, because the current at a particular time depends on the value of all the electric fields up to that time, since the past behavior of the electric field affects how close ions are to the boundaries between polycationic and polyanionic regions. I used a deep o net since they have more versatility than FNOs, in that they don't require all the input data points to be evenly spaced. That wasn't a problem with this specific data set, but I am working with experimentalists who are working on polymer diodes as well, who may not always be able to get such clean data, and I am interested in potentially later trying to extend to use experimental data.

**Model**

The model used a Deep O Net to predict the difference between the current and the electric field:

$I_\text{pred}(t) = E(t) + R_\theta (t, E)$

The branch net took as input the electric field at all times (a 1x801 vector) and output a 1x256 vector which was dotted with the output of the trunk net, which took a single time as input.

The structure of the branch net was: (801 x 256) linear layer -> Tanh activation layer -> (256 x 256) linear layer -> Tanh activation layer -> (256 x 256) linear layer

The structure of the trunk net was: (1 x 64) linear layer -> Tanh activation layer -> (64 x 64) linear layer -> Tanh activation layer -> (64 x 256) linear layer

**Training**

The 100 trajectories were divided into 3 data sets: 70 in the training set, 15 in the validation set, and 15 in the test set. In each training cycle, I picked one time point randomly from the entire data set and predicted the current at that time for that trajectory given the time and electric field value over the trajectory that time point was from. I used `pytorch`'s `ADAM` optimizer and trained for 30000 cycles, with learning rates of 0.001, 0.0002, and 0.0001 for each set of 10000 cycles.

