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
- Setup GUI and bind properties
- Setup soma psp graph
- Setup noise
- Setup stimulus

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


# Junk
Intercept form:
x/a + y/b = 1
where:
a = x intercept (a,0) => x/a = 1 => x = 1*a
b = y intercept (0,b)


Problem:
Given 
y = mx+b
b = y/mx
if y = 10 and x = 5 then


y = (-a/c * x) + b
Move y intercept but lock x intercept to N
If c = 1 and a increases then the x intercept moves to the right.
Looping on x {0 -> N} until y = 0 we obtain x intercept.
By changing m we can control the time it takes for y to reach 0.

xI = n
b=6 , c=1, a =  3 
b=4 , c=1, a = -2
b=2 , c=1, a = -1

if y = 4 and x = 2 what is the slope (m)
m = -2/1 = -2

