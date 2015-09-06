% MLTOOLS toolbox
% Version 0.135		03-Jun-2010
% Copyright (c) 2010, Neil D. Lawrence
% 
, Neil D. Lawrence
% MLPEXTRACTPARAM Extract weights and biases from an MLP.
% MVUEMBED Embed data set with MVU.
% LINEARPARAMINIT Initialise the parameters of an LINEAR model.
% MOGPROJECT Project a mixture of Gaussians to a low dimensional space.
% DOUBLEMATRIXWRITETOFID Writes a double matrix to an FID.
% LINEAREXPANDPARAM Update linear model with vector of parameters.
% RBFOUT Output of an RBF model.
% MVUOPTIMISE Optimise an MVU model.
% VECTORMODIFY Helper code for visualisation of vectorial data.
% MODELHESSIAN Hessian of error function to minimise for given model.
% LECREATE Laplacian eigenmap model.
% DNETTEST Test some settings for the density network.
% DNETOBJECTIVE Wrapper function for Density Network objective.
% ISOMAPRECONSTRUCT Reconstruct an isomap form component parts.
% RBFPERIODICOUTPUTGRAD Evaluate derivatives of RBFPERIODIC model outputs with respect to parameters.
% MLPLOGLIKEGRADIENTS Multi-layer perceptron gradients.
% RBFDISPLAY Display an RBF network.
% RBFPERIODICCREATE Create a RBFPERIODIC model.
% LINEARCREATE Create a linear model.
% LFMRESULTSDYNAMIC Load a results file and visualise them.
% PPCAPOSTERIORMEANVAR Mean and variances of the posterior at points given by X.
% MODELTIEPARAM Tie parameters of a model together.
% VITERBIALIGN Compute the Viterbi alignment.
% MODELPOINTLOGLIKELIHOOD Compute the log likelihood of a given point.
% PPCAPOSTERIORVAR Mean and variances of the posterior at points given by X.
% LVMSCATTERPLOT 2-D scatter plot of the latent points.
% PPCAEMBED Embed data set with probabilistic PCA.
% MULTIMODELLOGLIKELIHOOD Log likelihood of MULTIMODEL model.
% MULTIMODELEXTRACTPARAM Extract parameters from the MULTIMODEL model structure.
% PPCAOPTIONS Options for probabilistic PCA.
% KBREXTRACTPARAM Extract parameters from the KBR model structure.
% MOGOPTIONS Sets the default options structure for MOG models.
% LINEAROPTIMISE Optimise a linear model.
% DNETGRADIENT Density Network gradient wrapper.
% KPCAEMBED Embed data set with kernel PCA.
% KBRCREATE Create a KBR model.
% MLPLOGLIKELIHOOD Multi-layer perceptron log likelihood.
% DEMSWISSROLLFULLLLE4 Demonstrate LLE on the oil data.
% DEMSWISSROLLLLE4 Demonstrate LLE on the oil data.
% DNETLOADRESULT Load a previously saved result.
% MLPEXPANDPARAM Update mlp model with new vector of parameters.
% LVMCLICKVISUALISE Visualise the manifold using clicks.
% LINEARLOGLIKELIHOOD Linear model log likelihood.
% MLPLOGLIKEHESSIAN Multi-layer perceptron Hessian.
% MOGOPTIMISE Optimise an MOG model.
% RBFPERIODICPARAMINIT RBFPERIODIC model parameter initialisation.
% DEMSWISSROLLFULLLLE1 Demonstrate LLE on the oil data.
% RBFPERIODICEXTRACTPARAM Extract parameters from the RBFPERIODIC model structure.
% FINDNEIGHBOURS find the k nearest neighbours for each point in Y.
% MULTIMODELEXPANDPARAM Create model structure from MULTIMODEL model's parameters.
% MOGCREATE Create a mixtures of Gaussians model.
% RBFEXPANDPARAM Update rbf model with new vector of parameters.
% RBFPERIODICOUTPUTGRADX Evaluate derivatives of a RBFPERIODIC model's output with respect to inputs.
% SPECTRUMMODIFY Helper code for visualisation of spectrum data.
% MOGTWODPLOT Helper function for plotting the labels in 2-D.
% MOGUPDATEMEAN Update the means of an MOG model.
% MULTIMODELPARAMINIT MULTIMODEL model parameter initialisation.
% MULTIMODELCREATE Create a MULTIMODEL model.
% DEMOILLLE1 Demonstrate LLE on the oil data.
% DNETOUTPUTGRADX Evaluate derivatives of DNET model outputs with respect to inputs.
% DEMOILLLE4 Demonstrate LLE on the oil data.
% MOGESTEP Do an E-step on an MOG model.
% LLEEMBED Embed data set with LLE.
% KBRDISPLAY Display parameters of the KBR model.
% LINEAROUTPUTGRAD Evaluate derivatives of linear model outputs with respect to parameters.
% MODELGETOUTPUTWEIGHTS Wrapper function to return output weight and bias matrices.
% MVUDECONSTRUCT break MVU in pieces for saving.
% SPECTRUMVISUALISE Helper code for showing an spectrum during 2-D visualisation.
% LEOPTIONS Options for a Laplacian eigenmaps.
% RBFOPTIMISE Optimise RBF for given inputs and outputs.
% ISOMAPCREATE isomap embedding model.
% MODELLOGLIKELIHOOD Compute a model log likelihood.
% MULTIMODELDISPLAY Display parameters of the MULTIMODEL model.
% MODELEXPANDPARAM Update a model structure with parameters.
% LVMSCATTERPLOTCOLOR 2-D scatter plot of the latent points with color.
% MOGUPDATECOVARIANCE Update the covariances of an MOG model.
% MOGUPDATEPRIOR Update the priors of an MOG model.
% SPECTRALUPDATELAPLACIAN Update the Laplacian using graph connections.
% MODELSETOUTPUTWEIGHTS Wrapper function to return set output weight and bias matrices.
% MODELPOSTERIORMEANVAR Mean and variances of the posterior at points given by X.
% MODELGRADIENTCHECK Check gradients of given model.
% SPRINGDAMPERSVISUALISE Helper code for showing an spring dampers during 2-D visualisation.
% PARAMNAMEREGULAREXPRESSIONLOOKUP Returns the indices of the parameter containing the given regular expression.
% DEMMPPCA1 Demonstrate MPPCA on a artificial dataset.
% DEMSWISSROLLLLE1 Demonstrate LLE on the oil data.
% MOGMEANCOV Project a mixture of Gaussians to a low dimensional space.
% ISOMAPEMBED Embed data set with Isomap.
% DNETRECONSTRUCT Reconstruct an DNET form component parts.
% LLEOPTIMISE Optimise an LLE model.
% MLPOUT Output of an MLP model.
% LMVUEMBED Embed data set with landmark MVU
% DEMSWISSROLLLLE3 Demonstrate LLE on the oil data.
% RBFCREATE Wrapper for NETLAB's rbf `net'.
% RBFOPTIONS Default options for RBF network.
% VECTORVISUALISE  Helper code for plotting a vector during 2-D visualisation.
% ISOMAPOPTIONS Options for a isomap.
% PPCARECONSTRUCT Reconstruct an PPCA form component parts.
% MODELPOSTERIORVAR variances of the posterior at points given by X.
% MLTOOLSTOOLBOXES Load in the relevant toolboxes for the MLTOOLS.
% KBROPTIMISE Optimise a KBR model.
% MVUOPTIONS Options for a MVU.
% LVMCLASSVISUALISE Callback function for visualising data.
% MODELCREATE Create a model of the specified type.
% MODELDISPLAY Display a text output of a model.
% LVMPRINTPLOT Print latent space for learnt model.
% LLEOPTIONS Options for a locally linear embedding.
% RBFOUTPUTGRADX Evaluate derivatives of a RBF model's output with respect to inputs.
% LFMVISUALISE Visualise the outputs in a latent force model
% KBROPTIONS Create a default options structure for the KBR model.
% LFMCLASSVISUALISE Callback function to visualize LFM in 2D
% KBROUT Compute the output of a KBR model given the structure and input X.
% KBREXPANDPARAM Create model structure from KBR model's parameters.
% MODELOUT Give the output of a model for given X.
% LEOPTIMISE Optimise an LE model.
% DEMOILLLE2 Demonstrate LLE on the oil data.
% DNETWRITERESULT Write a DNET result.
% MAPMODELREADFROMFID Load from a FID produced by C++ code.
% LINEAREXTRACTPARAM Extract weights from a linear model.
% DEMSWISSROLLFULLLLE2 Demonstrate LLE on the oil data.
% MLPOPTIMISE Optimise MLP for given inputs and outputs.
% MULTIMODELOPTIONS Create a default options structure for the MULTIMODEL model.
% MODELSAMP Give a sample from a model for given X.
% SPECTRALUPDATEX Update the latent representation for spectral model.
% RBFPERIODICLOGLIKEGRADIENTS Gradient of RBFPERIODIC model log likelihood with respect to parameters.
% MODELOUTPUTGRAD Compute derivatives with respect to params of model outputs.
% MODELWRITETOFID Write to a stream a given model.
% DISTANCEWARP Dynamic Time Warping Algorithm
% RBFPERIODICDISPLAY Display parameters of the RBFPERIODIC model.
% DNETESTEP Do an E-step (update importance weights) on an Density Network model.
% LINEAROUTPUTGRADX Evaluate derivatives of linear model outputs with respect to inputs.
% RBFPERIODICLOGLIKELIHOOD Log likelihood of RBFPERIODIC model.
% LERECONSTRUCT Reconstruct an LE form component parts.
% DNETUPDATEOUTPUTWEIGHTS Do an M-step (update parameters) on an Density Network model.
% IMAGEVISUALISE Helper code for showing an image during 2-D visualisation.
% MODELREADFROMFILE Read model from a file FID produced by the C++ implementation.
% ISOMAPDECONSTRUCT break isomap in pieces for saving.
% LVMSCATTERPLOTNEIGHBOURS 2-D scatter plot of the latent points with neighbourhood.
% SMALLRANDEMBED Embed data set with small random values.
% DEMOILLLE3 Demonstrate LLE on the oil data.
% MVURECONSTRUCT Reconstruct an MVU form component parts.
% MOGLOGLIKELIHOOD Mixture of Gaussian's log likelihood.
% LLERECONSTRUCT Reconstruct an LLE form component parts.
% PPCACREATE Density network model.
% MODELOUTPUTGRADX Compute derivatives with respect to model inputs of model outputs.
% DNETOPTIMISE Optimise an DNET model.
% MODELEXTRACTPARAM Extract the parameters of a model.
% RBFPERIODICOPTIONS Create a default options structure for the RBFPERIODIC model.
% MLPCREATE Multi-layer peceptron model.
% MOGLOWERBOUND Computes lower bound on log likelihood for an MOG model.
% MODELPARAMINIT Initialise the parameters of the model.
% PPCADECONSTRUCT break PPCA in pieces for saving.
% DNETEXPANDPARAM Update dnet model with new vector of parameters.
% RBFPERIODICEXPANDPARAM Create model structure from RBFPERIODIC model's parameters.
% LVMVISUALISE Visualise the manifold.
% RBFOUTPUTGRAD Evaluate derivatives of rbf model outputs with respect to parameters.
% MODELREADFROMFID Load from a FID produced by C++ code.
% DNETOPTIONS Options for a density network.
% PARAMNAMEREVERSELOOKUP Returns the index of the parameter with the given name.
% MODELLOADRESULT Load a previously saved result.
% LEDECONSTRUCT break LE in pieces for saving.
% ISOMAPOPTIMISE Optimise an ISOMAP model.
% DNETOUT Output of an DNET model.
% MODELLOGLIKEGRADIENTS Compute a model's gradients wrt log likelihood.
% LLEDECONSTRUCT break LLE in pieces for saving.
% MODELOPTIONS Returns a default options structure for the given model.
% MATRIXREADFROMFID Read a matrix from an FID.
% MULTIMODELLOGLIKEGRADIENTS Gradient of MULTIMODEL model log likelihood with respect to parameters.
% MODELADDDYNAMICS Add a dynamics kernel to the model.
% DNETPOSTERIORMEANVAR Mean and variances of the posterior at points given by X.
% MLPOPTIONS Options for the multi-layered perceptron.
% LVMRESULTSDYNAMIC Load a results file and visualise them.
% LINEARDISPLAY Display a linear model.
% KBROUTPUTGRAD Evaluate derivatives of KBR model outputs with respect to parameters.
% LVMLOADRESULT Load a previously saved result.
% LVMRESULTSCLICK Load a results file and visualise them with clicks
% MAPPINGOPTIMISE Optimise the given model.
% LINEAROPTIONS Options for learning a linear model.
% DNETEXTRACTPARAM Extract weights and biases from an DNET.
% DNETCREATE Density network model.
% MLPDISPLAY Display the multi-layer perceptron model.
% MLPOUTPUTGRAD Evaluate derivatives of mlp model outputs with respect to parameters.
% MODELTEST Run some tests on the specified model.
% PPCAOUT Output of an PPCA model.
% DEMSWISSROLLLLE2 Demonstrate LLE on the oil data.
% LVMCLASSCLICKVISUALISE Callback function for visualising data in 2-D with clicks.
% LVMSCOREMODEL Score model with a GP log likelihood.
% DNETLOWERBOUND Computes lower bound on log likelihood for an DNET model.
% LVMCLASSVISUALISEPATH Latent variable model path drawing in latent space.
% KBRPARAMINIT KBR model parameter initialisation.
% MOGPRINTPLOT Print projection of MOG into two dimensions.
% LINEARLOGLIKEGRADIENTS Linear model gradients.
% MODELOBJECTIVE Objective function to minimise for given model.
% LVMNEARESTNEIGHBOUR Give the number of errors in latent space for 1 nearest neighbour.
% MODELWRITERESULT Write a model to file.
% LLECREATE Locally linear embedding model.
% DNETDECONSTRUCT break DNET in pieces for saving.
% SPRINGDAMPERSMODIFY Helper code for visualisation of springDamper data.
% DNETLOGLIKELIHOOD Density network log likelihood.
% LVMTHREEDPLOT Helper function for plotting the labels in 3-D.
% LVMTWODPLOT Helper function for plotting the labels in 2-D.
% LINEAROUT Obtain the output of the linear model.
% MLPOUTPUTGRADX Evaluate derivatives of mlp model outputs with respect to inputs.
% MODELGRADIENT Gradient of error function to minimise for given model.
% DNETOUTPUTGRAD Evaluate derivatives of dnet model outputs with respect to parameters.
% LVMSETPLOT Sets up the plot for visualization of the latent space.
% RBFPERIODICOUT Compute the output of a RBFPERIODIC model given the structure and input X.
% MODELOPTIMISE Optimise the given model.
% MOGSAMPLE Sample from a mixture of Gaussians model.
% DEMSWISSROLLFULLLLE3 Demonstrate LLE on the oil data.
% DNETUPDATEBETA Do an M-step (update parameters) on an Density Network model.
% MLPPARAMINIT Initialise the parameters of an MLP model.
% DNETLOGLIKEGRADIENTS Density network gradients.
% RBFEXTRACTPARAM Wrapper for NETLAB's rbfpak.
% IMAGEMODIFY Helper code for visualisation of image data.
% DOUBLEMATRIXREADFROMFID Read a full matrix from an FID.
% MVUCREATE Maximum variance unfolding embedding model.
