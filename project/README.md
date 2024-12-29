# leuron10_dart

A simplified linear version of Deuron9.

# Simulation
Simulation works using a two step process via an input and output staging process. The first step is integration and second is propagation.

The simulation is continuous and runs until it is stopped. The graphs scroll from right to left showing activity as it happens.

# Controls
- Add synapse weight code
- Manipulate properties of synapse and soma
  - Generate new random weights
  - Min/max/normal
  - Soma threshold
  - STDP window
    - Depression width in ms
    - Potentiation width in ms


## Network simulation
This project does not implement a network. It focuses on a single neuron.

However, looking forward:
Each neuron has an Output (aka Axon). During the current step each neuron processes it's Input. At the next step each neuron's next output is asserted/placed at the axon output.

This way each neuron can process what is currently on each of the synapse inputs before a pre-neuron presents it next output value.

Because this simulation has only one neuron it has only inputs that are fed by "streams". 

## STDP windows
DEP and POT must decay from *surge* to 0.0 within their defined window (in milliseconds). Time progresses at 0.1ms per step this means, what is the decay factor per step. That is the slope of the line. If we use Lerp then we normalise *t* so it's between 0.0->1.0. As *t* moves towards 1.0 the value moves from *surge* to 0.0.



# Tasks
- add gui code to adjust phase of selected stimulus source.
- Add parameters for triplet model. Add a gui feature such that each parameter can be locked with the other parameters. For example, if you drag A1 and A2, O1, O2 are also checked then they should drag in sync. Any parameter checked is lock/synced with the other check parameters.
- Setup soma psp graph
- Mean post synaptic firing rate (1) page 2 section [2].

# Bugs
- {Solved}: why is preTrace capping out? because if dt is the same you eventually keep adding at the same point in the trace.

# Step 1
On Step a neuron reads the output of each stream, performs integration to generate an output. In a multi-neuron network the ouput would be sent to an Axon's pre-output waiting for the next step.

Before the next step, each stream presents its next output.

Repeat by going back to step 1.

# Documents

## Diagrams
- [EvoTron diagrams](https://app.diagrams.net/#G1DOEwB_2iBFdxoEozULfFuroQ0wh1Bnad#%7B%22pageId%22%3A%22Iami22863Eb5rShz9eBr%22%7D)

# Neurons
Instead of using equations we blend between functions and rules.

- refractory period
- 10ms pre-post spike window
- linear line y = mx+b

# Running sim
In order for the simulation to run the neuron needs to configured. This means either:
1) Loading presets from json
2) Generating new presets

In addition there are runtime properties that are loaded when the app starts, for example, Duration, Active synapse etc.

# Project structure
Properties and Settings:
- Properties are for the gui/app, Parameters model presets.

## : Parameters
A neuron has parameters that control how the neuron responds to stimuli. Eventually these are the "things" that are evolved in [EvoTron](https://docs.google.com/document/d/1_DhbeHJvRaVRzSCakr8r48-MwWL_gglYKBINBmypsjA/edit#heading=h.66vap1gkszux).

Parameters are stored in json as: *parameters.json". This file has all the parms saved from a previous simulation. You can either load them or generate new parms via a button. The file has each model component, for example, Neuron, Soma, Synapse(s)

There is an additional json file called *template.json*. This has a set of basic starter parameters that create a reasonable response. In EvoTron these parms are evolved.

----
# Project creation
```sh
flutter create --platform linux --template app leuron10_dart
```

# JSON via serializable
```dart
dart run build_runner build --delete-conflicting-outputs
```

# Launch config
```json
        {
            "name": "Leuron10",
            "cwd": "leuron10_dart",
            "request": "launch",
            "type": "dart"
        },
```

# GUI
```
--------------------------------------------------
|---- graph ------------------|/  Tab  \/  Tab  \|
|                             |________|_________|
|                             |      Panel       |
|                             |                  |
|---- graph ------------------|__________________|
|                             |                  |
|                             |      Panel       |
|                             |                  |
|---- graph ------------------|__________________|
|...                          |                  |
--------------------------------------------------
```

Window size hack:

NOTE: This is just a hack because the *window_manager* package doesn't work on linux.

Modify the code in *linux/my_application.cc* and add ```*1.5```
```c
gtk_window_set_default_size(window, 1280*1.5, 720*1.5);
```

# Additional concepts
The following are additional environment effects that still need to be added to the simulation.
- Homeostatic plasticity
- Modulators
- Eventually *memory* needs to be added when full network is built.

# References
- [1] a-triplet-spike-timing-dependent-plasticity-model-generalizes-the-bienenstock-cooper-munro-rule.pdf
  - I also used starter values for "A"s from page 2[4]. They used the minimal model where A2+ = 0
- [2] Phenomenological models of synaptic plasticity based on spike timing.pdf
  - page 462 section 2.3: Mean firing rate. Covers an approach by adding each "A" which is equivalent.
    - in the case of Hebbian *long-term potentiation*, traces left by presynaptic spikes need to be combined with postsynaptic spikes, whereas *short-term plasticity* can be seen as induced by traces of presynaptic spikes, independent of the state of the postsynaptic neuron
  - Section 4.2: The temporal distance of the spikes in the pair is of the order of a few to tens of milliseconds, whereas the temporal distance between the pairs is of the order of hundreds of milliseconds to seconds.
  - Section 4.2.1: The new feature of the rule is that LTP is induced by a triplet effect: the weight change is proportional to the value of the presynaptic trace x j evaluated at the moment of a postsynaptic spike and also to the slow postsynaptic trace yi2 remaining from previous postsynaptic spikes. Also talks about efficacy.
  - Section 4.2.2: suppression via efficacy.
- [3] Diverse synaptic plasticity mechanisms orchestrated to form and retrieve memories in spiking neural networks.pdf
  - Talks about *cell assemblies* or neural networks, and memory recall.
- [4] New_models_of_synaptic_plasticity.pdf
  - Slides with exponential equations from SpiNNiker.
- [5] The temporal paradox of Hebbian learning and homeostatic plasticity.pdf
  - stable models arise from a weight dependence in the learning rule such that high (low) synaptic strength makes LTP (LTD) weaker [53, 70–74]
- [6a] Stability versus Neuronal Specialization for STDP- LongTail Weight Distributions Solve the Dilemma.PDF
  - Introduces logSTDP.
- [6b] Characterization of Generalizability of Spike Timing Dependent Plasticity Trained Spiking Neural Networks.pdf
  - talks about logSTDP
