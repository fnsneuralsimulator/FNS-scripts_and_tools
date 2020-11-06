Here you will find two scripts:

FNSvisualization_v2.py - meant to be a tool to produce dynamical graphs (in video format) for FNS simulation activity. This pipeline allows to visualize at the neuron scale (see v_neuronViz.avi as example), and to produce a visualization averaging neurons' activity into nodes (see v_nodeViz.avi as example). 

gephiConvert.py - allows the user to generate two csv files (nodes.csv and edges.csv) that contains activity information at the level of neurons to be imported in Gephi sorftware. Remember that FNS has a switcher (-g) that allows you to efficiently generate a gephi compliant file, nevertheless that file doesn't come by now with activity information to animate the network (work in progress). Thus, the file will be deprecated as soon as the simulator can handle this option. 

To run either of those scripts we recommend to install requirements: pip install -r requirements.txt (in command line). 

More information about each script can be found in the documentation inside them. 
